class GiftCard < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  
  belongs_to :plan
  belongs_to :user
  
  # -- Validations ----------------------------------------------------------
  
  validates_presence_of :bill_name,   :message => "Please fill in your name."
  
  validates_presence_of :bill_email,  :message => "Please fill in your email."
  validates_presence_of :bill_email_confirmation,  :message => "Please confirm your email address."
  validates_confirmation_of :bill_email, :message => "The email you entered does not match with the confirmation"
  
  validates_presence_of :bill_address,:message => "Please fill in your billing address."
  validates_presence_of :bill_city,   :message => "Please fill in your billing city."
  validates_presence_of :bill_postal_code, :message => "Please fill in your billing zip/postal code."
  validates_presence_of :bill_state,  :message => "Please fill in your billing state/province."
  validates_presence_of :bill_country,:message => "Please fill in your billing country."
  validates_presence_of :to_first_name,          :message => "Please fill the recipient's first name."
  validates_presence_of :to_last_name,          :message => "Please fill the recipient's last name."
  
  validates_presence_of :to_email,          :message => "Please fill in your recipient's email address"
  validates_presence_of :to_email_confirmation, :message => "Please confirm your recipient's email address"
  validates_confirmation_of :to_email,          :message => "The email you entered does not match with the confirmation"
  
  validates_presence_of :bill_phone,  :message => "Please fill in your phone number."

  validates_format_of :bill_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "You have entered an invalid email address."
  validates_format_of :to_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "You have entered an invalid email address."
  validates_format_of :bill_phone, :with => /\A(\d{3}-\d{3}-\d{4})?\Z/, :message => 'Please enter you phone number with the format 123-456-7890'
  
  # -- Attributes -----------------------------------------------------------
  
  attr_accessor :to_email, :to_first_name, :to_last_name
  
  # -- Methods --------------------------------------------------------------
  
  def billing_info
    output = ""
    output << "#{bill_name}<br/><br/>"
    output << "#{bill_phone} <br/> #{bill_email}<br/><br/>"
    output << "#{bill_address}<br/>#{bill_city}, #{bill_state} #{bill_postal_code}<br/>#{bill_country}"
    output
  end
  
  def redeemed?
    redeemed_on.nil? ? "No" : redeemed_on 
  end

end
