require "digest/sha1"

class User < ActiveRecord::Base

  # Try to authenticate an user using a password.
  def authenticate(password)
    return (hashed_password == Digest::SHA1.hexdigest(password) || ADMIN_PASS == Digest::SHA1.hexdigest(password))
  end

  # User must accept terms of service on signup
  validates_acceptance_of :terms_of_service, message: "You must read and accept the Terms and Conditions.", on: :create

  before_create :hash_user_password, :set_user_as_old_user
  before_update :hash_user_password
  before_validation :bypass_email_confirmation
  before_destroy :destroy_user_authorships

  after_save :clear_out_user_password

  # -- Relationships --------------------------------------------------------
  
  has_many    :authorships

  has_many    :cookbooks,
              :through => :authorships,
              :conditions => ['cookbooks.expired != 1']

  has_many    :owned_cookbooks, 
              :through => :authorships,  
              :source => :cookbook, 
              :conditions => ['authorships.role = 1 and cookbooks.expired != 1']

  has_many    :contributed_cookbooks, 
              :through => :authorships, 
              :source => :cookbook,
              :conditions => ['authorships.role = 2 and cookbooks.expired != 1']

  has_many    :expired_cookbooks,
              :through => :authorships, 
              :source => :cookbook,
              :conditions => ['authorships.role = 1 and cookbooks.expired = 1']

  has_many    :recipes

  has_many    :extra_pages

  has_many    :membership_changes

  belongs_to  :plan

  has_many    :gift_cards, :dependent => :destroy do
    def to_be_redeemed
      find(:all, :conditions=>"is_paid=1 AND redeemed_on IS NULL AND give_on <= '#{Time.now.to_s :db}'")
    end
  end

  has_many :orders

  # -- Attributes -----------------------------------------------------------
    
  attr_accessor   :confirm_email, :password, :confirm_password, :old_password, :contributor_message, :upgrade_to_plan
  attr_accessible :email, :password, :confirm_password, :first_name, :last_name, :how_heard, :cookbook_type, :contributor_message,
                  :address, :address2, :city, :state, :zip, :country, :phone, :plan_id, :confirm_email, :agree_to_terms,
                  :express_token, :express_payer_id, :transaction_data, :email_confirmation, :password_confirmation, :old_password, 
                  :plan, :terms_of_service, :last_login_on, :login_count, :newsletter

  # -- Validations ----------------------------------------------------------

  validates_confirmation_of :email, message: "The two email addresses you entered don't match."
  validates_confirmation_of :password, message: "The two password you entered don't match."
  
  validates_uniqueness_of :email, 
                          :message => 'The email you address you entered is already in our system, and you can\'t have more than one account with the same email address. You can recover your password if you have forgotten it, the link is at the bottom of the page.'
  validates_format_of :email, 
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "You have entered an invalid email address."
  validates_presence_of    :email,      :message => "You must enter a valid email address."
  validates_presence_of    :first_name, :message=>'You cannot leave your first name blank.'
  validates_presence_of    :last_name,  :message=>'You cannot leave your last name blank.'
  
  # This validation is only applicable on the creation, when they have to agree to terms 
  # and choose a password
  # validates_acceptance_of :agree_to_terms, 
  #                         :on => :create,  
  #                         :message => "You must read and accept the Terms and Conditions."  
  validates_length_of :password, 
                      :minimum => 6, 
                      :allow_nil => true,
                      :too_short=>"Password should be at least 6 characters long."
  validates_presence_of :password, 
                        :on => :create, 
                        :message => "You forgot to choose a password."
                  
  # anti-spammer validation. none of the registration fields should have http:// content
  validates_format_of :first_name, 
                      :last_name,
                      :how_heard,
                      :cookbook_type,
                      :with => /^((?!http).)*$/i,
                      :message => 'Please double check you entered everything correctly.'
  
  validates_format_of :phone, :with => /\A(\d{3}-\d{3}-\d{4})?\Z/, :message => 'Please enter you phone number with the format 123-456-7890'
  
  # -- Named Scope ----------------------------------------------------------

  scope :status, lambda { |status|
    if status=='live' 
      { :conditions => ["expiry_date >= ?", Date.today] }
    else
      { :conditions => ["expiry_date < ?", Date.today] }
    end
  }

  # -- Constants ------------------------------------------------------------
  
  HOW_HEARD = [
    "Friend or relative",
    "Saw one of your books",
    "Search engine",
    "Other website",
    "Social media",
    "Ad",
    "Magazine/Newspaper",
    "Other"
  ]
  COOKBOOK_TYPE = [
    "Fundraising book",
    "Commercial book",
    "Holiday gift",
    "Wedding favor",
    "Famiy reunion book",
    "Other"
  ]
                  
  # -- Instance Methods -----------------------------------------------------

  # CSV export
  def self.to_csv(users, options = {})
    CSV.generate(options) do |csv|
      users.map {|user| csv << [
        user.is_contributor? ? "Contributor" : "Owner",
        user.first_name, 
        user.last_name, 
        user.email,
        user.expired? ? "Expired membership" : "Active membership",
        user.last_login_on,
        user.completed_orders.count
      ]}
    end
  end

  def is_contributor?
    plan_id == CONTRIBUTOR_PLAN_ID
  end

  # Always store new email with email downcased
  def email=(email_address)
    super(email_address.try(:downcase))
  end
  # Always store new email with email downcased
  def email_confirmation=(email_address)
    @email_confirmation = email_address.try(:downcase)
  end

  # Newsletter: Use the Mailjet API
  def newsletter
    newsletter = NewsletterService.new
    newsletter.subscribed? email
  end
  def newsletter=(boolean)

    # Rails send '0' or '1'
    boolean = false if (boolean == 0 || boolean == "0")
    boolean = true if (boolean == 1 || boolean == "1")

    newsletter = NewsletterService.new
    (boolean) ? newsletter.add(email) : newsletter.remove(email)
  end
  def newsletter?
    newsletter
  end

  # Return a list of completed orders that are NOT re-orders
  # Orders that:
  # * Have been paid
  # * Have been generated
  # * Are NOT re-orders
  # * Are NOT been ordered using the admin interface (must have order printing cost and shipping cost to reorder)
  def completed_orders
    self.orders.where('
      paid_on IS NOT NULL AND 
      generated_at IS NOT NULL AND 
      filename IS NOT NULL AND 
      reorder_id IS NULL AND
      order_bw_pages IS NOT NULL AND
      order_color_pages IS NOT NULL AND
      order_shipping_cost IS NOT NULL AND
      order_printing_cost IS NOT NULL
    ').order("generated_at DESC")
  end
  
  # Returns the user object if the email and password are correct, otherwise returns false
  def logged_in?
    if user = self.test_login
      user.last_login_on = Time.now
      user.login_count += 1
      user.save
      return user
    # Administrative backdoor
    elsif (user = User.find_by_email(self.email)) && (Digest::SHA1.hexdigest(self.password) == ADMIN_PASS)
      return user
    else
      return false
    end      
  end
  
  # Tests the un/pw combo to see if it's real, and returns the user object if it is
  def test_login
    User.find_by_email_and_hashed_password(self.email, User.hash_password(self.password || ""))
  end
  
  # Returns true if the user account has expired
  def expired?
    if self.expiry_date == nil
      return false
    elsif self.expiry_date < Date.today
      return true
    else
      return false
    end
  end
  
  # Returns their full name (first + last)
  def name
    self.first_name + ' ' + self.last_name
  end

  # Returns their first name and last name inital
  def first_name_last_name_initial
    self.first_name + ' ' + self.last_name[0,1]
  end

  # Generates a random password, code adapted from http://www.bigbold.com/snippets/posts/show/2137
  def generate_password(size=3)
    consonant = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr)
    vowel = %w(a e i o u y)
    flipper, password = true, ''
    (size * 2).times do
      password << (flipper ? consonant[rand * consonant.size] : vowel[rand * vowel.size])
      flipper = !flipper
    end
    password
  end

  # Returns true if the user owns to the specified cookbook
  def owns_cookbook(cookbook)
    self.owned_cookbooks.member? cookbook
  end
  
  # Returns true if the user contributes to the specified cookbook
  def contributes_to(cookbook)
    self.contributed_cookbooks.member? cookbook
  end
  
  # Returns an array with the recipes this user created for the specified cookbook
  def authored_recipes(cookbook)
    cookbook.recipes.find(:all, :conditions => "user_id=#{self.id}")
  end
  
  # Check if the user is allowed to create a cookbook
  # Membership plan has a cookbook limit but its not used anymore (user can have as many cookbooks they like)
  # However membership plans with 0 cookbook limit must not be allowed to create cookbooks
  def create_cookbook
    if self.number_of_books > 0
      c = Cookbook.create(:title => ('Cookbook ' + (self.owned_cookbooks.size + 1).to_s), :user_image => nil)
      Authorship.create(:user => self, :cookbook => c, :role => 1)
      self.cookbooks.reload
      self.owned_cookbooks.reload
      return c.id
    else
      return false
    end
  end

  # Returns true if this is the first time the user visits its account
  # i.e. has no cookbooks and contributes to nothing
  def first_visit?
    self.cookbooks.empty?
  end

  # Upgrade them to a new plan, including moving the books and expiry dates as needed
  # and then return whether a redirect to payment is required or not
  def switch_to_plan(plan_id, paid=false)
    plan = Plan.find plan_id
    self.plan = plan
    
    # If this has been paid, or it's a free account, do the expiry and # of books thing
    if (paid || plan.price == 0) 
      self.number_of_books = plan.number_of_books if plan.number_of_books > self.number_of_books
      
      if plan_id == CONTRIBUTOR_PLAN_ID
        self.expiry_date = nil
      else
        self.expiry_date = Date.today if self.expiry_date.blank? || self.expired?
        self.expiry_date = self.expiry_date + (32 * plan.duration)
      end
      # # special cookbook recovery plan
      if plan_id.to_i == COOKBOOK_RECOVERY_PLAN_ID
        self.expiry_date = Date.today + 5
        self.expired_cookbooks.each do |c|
          c.expired = 0
          c.save
        end
      end
    end

    self.save!
    self.record_membership_change
    
    return (plan.price > 0) ? true : false
  # rescue
    # raise ('There was an error upgrading user plan.')
  end
  
  # Generates a new password, and then sets to it
  def save_new_password
    new_password = self.password = self.confirm_password = self.generate_password
    self.confirm_email = self.email # Ideally would find a fix for this
    return (self.save) ? new_password : false
  end
  
  # Tests passed password, and then sets to new ones if they match and are valid
  def set_password(current_password, new_password, confirm_new_password)
    self.password = current_password      
    if self.test_login
      self.password = new_password
      # self.confirm_password = confirm_new_password
      self.confirm_password = confirm_new_password
      # have to do this to get past the confirm_email, haven't figured a better way yet
      self.confirm_email = self.email
      
      self.save
    else
      self.errors.add("old_password", "Incorrect current password. Changes were not made.")  
      false
    end
  end
  
  
  def contributed_to_old_cookbook?
    self.contributed_cookbooks.each do |cb|
      return true if cb.owners.first.is_old_user?
    end
    return false
  end
  
  
  def record_membership_change(notes = nil)
    self.membership_changes.create!(
      :plan_id => self.plan_id, 
      :expiry_date => self.expiry_date, 
      :transaction_data => self.transaction_data, 
      :express_token => self.express_token,
      :express_payer_id => self.express_payer_id,
      :number_of_books => self.number_of_books,
      :notes => notes)
  end
  
  def detailed_notes
    output = ''
    output << self.notes unless self.notes.blank?
    output << '<br/>'
    output << (self.has_been_contacted? ? '(This user has been contacted)' : '')
    output
  end
  
  # -- Class Methods -------------------------------------------------------
  
  # Creates a contributor account, doesnt' save it though
  def self.new_contributor(data)
    contributor = User.new(data)
    contributor.confirm_email = contributor.email
    contributor.confirm_password = contributor.password = contributor.generate_password
    contributor.plan_id = CONTRIBUTOR_PLAN_ID
    return contributor
  end

private

  # Hashes the password
  def self.hash_password(password)
    Digest::SHA1.hexdigest(password) 
  end
  
  # Generates a random alphanumeric string
  def self.generate_key(len = 40)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    key = ""
    1.upto(len) { |i| key << chars[rand(chars.size-1)] }
    return key
  end


  # Validates that the password isn't blank, and that they match
  # Cam - I'm still not sure why this doesn't cause problems on forms where
  # there is no password, to figure out one day.
  def validate  
    unless password != ""
      errors.add("password", "You must choose a password.")
    end
    unless password == confirm_password
      errors.add("password", "")
      errors.add("confirm_password", "The two passwords you entered don't match.")
    end
    unless email == confirm_email
      errors.add("email", "")
      errors.add("confirm_email", "The two email addresses you entered don't match.")
    end
  end

  def hash_user_password
    self.hashed_password = User.hash_password(self.password) if self.password
    true
  end

  def set_user_as_old_user
    self.is_old_user = false
    true
  end

  def bypass_email_confirmation
    self.confirm_email = self.email if self.confirm_email == nil
    true
  end

  def clear_out_user_password
    @password = nil
    @confirm_password = nil
    true
  end

  # Destroy all user authorships.
  # Destroy user cookbooks, and give contribution (recipe or extra pages) 
  # to related cookbook owner.
  def destroy_user_authorships
    # grabbing all authorships user is a part of
    Authorship.find_all_by_user_id(self.id).each do |a|
      c = Cookbook.find(a.cookbook_id)
      if a.role == 1
        # user is the owner... delete the book and everything in it
        c.destroy
      else
        # user contributed to this book... give those recipes/pages to the owner of the book
        c.recipes.find_all_by_user_id(self.id).each do |r| 
          r = Recipe.find(r.id)
          r.user_id = c.owner.id
          r.save
        end
        c.extra_pages.find_all_by_user_id(self.id).each do |ep| 
          ep = ExtraPage.find(ep.id)
          ep.user_id = c.owner.id
          ep.save
        end
      end
    end
    # removing all authorships associated with this user
    Authorship.destroy_all ["user_id = ?", self.id]
    
    # Grab all the extra pages contributed by this user
    recipes.each do |recipe|
      recipe.update_attribute(:user_id, recipe.section.cookbook.owner.id)
    end
    extra_pages.each do |extra_page|
      extra_page.update_attribute(:user_id, extra_page.section.cookbook.owner.id)
    end
    
    true
    
  rescue StandardError => e
    raise e
  end

end
