# class CookbookCostCalculator < ActiveRecord::Base
# see: https://github.com/rails/rails/tree/3-2-stable/activemodel
class CookbookCostCalculator
  include ActiveModel::Validations            # Validation support
  include ActiveModel::MassAssignmentSecurity # Support for mass assignment
  
  # Support for errors and mass assignment.
  attr_reader   :errors
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    @errors = ActiveModel::Errors.new(self)
  end

  attr_accessor :num_bw_pages, :num_color_pages, :num_books, :zip, :state, :country, :binding
  attr_accessible :num_bw_pages, :num_color_pages, :num_books, :zip, :state, :country, :binding

  # Used to see if we need validations for shipping address
  attr_accessor :validate_shipping

  validates :num_bw_pages, :num_color_pages, :num_books, :binding, presence: true
  validates :num_bw_pages, :num_color_pages, :num_books, numericality: {
    only_integer: true, 
    message: "This must be a number."
  }
  validates :num_books, numericality: {
    greater_than: 3,
    message: "Our minimum order is 4 books"
  }
  validates :num_books, numericality: {
    less_than_or_equal_to: Order::MAX_NUMBER_OF_BOOKS,
    message: "Please contact us to get our discounted pricing on orders of over #{Order::MAX_NUMBER_OF_BOOKS} cookbooks."
  }

  # These fields only need to be validated if we need shipping validation
  validates :zip, :state, :country, presence: true, :if => :validate_shipping
  validates :country, inclusion: { :in => %w{CA US} }, :if => :validate_shipping
  validates :state, inclusion: { :in => Order::STATES.keys }, :if => "validate_shipping && country == 'US'"
  validates :state, inclusion: { :in => Order::PROVINCES.keys }, :if => "validate_shipping && country == 'CA'"
  validate  :validate_zip_code, :if => :validate_shipping

  # Validate postal/zip code
  def validate_zip_code
    errors.add :zip, "Please use the format 55555."   if country =='US' && !Order.valid_postal_code?('US', zip)
    errors.add :zip, "Please use the format M5M 5M5." if country =='CA' && !Order.valid_postal_code?('CA', zip)
  end

  # Define and cache the printing cost
  def printing_cost
    @printing_cost ||= begin
      return false if !self.valid?
      pricing = PrintingCost.new quantity: num_books, binding: binding
      price = 0.0
      price += pricing.black_and_white_page * num_bw_pages * num_books
      price += pricing.color_page * num_color_pages * num_books
      price += pricing.binding * num_books
      price += pricing.cover_ink * num_books
      price += pricing.cover_lam * num_books
      price += pricing.prebind_papers * num_books
      price += pricing.end_papers * num_books
      price += pricing.case_binding * num_books
      price += pricing.outsourced_bindery
      price += pricing.order_fullfillment
      price += pricing.book_sample
      price *= 1 + pricing.heritage_mark_up
      '%.2f' % price.round(2)
    end
  end
  
  # Define and cache the shipping cost
  def shipping_cost
    @validate_shipping = true
    @shipping_cost ||= begin
      return false if !self.valid?
      shipping_cost = ShippingCost.new book_pages_number: num_pages, quantity: num_books, hard_cover: (binding == :hard)
      shipping_cost.origin(
        country: 'CA',
        province: 'ON',
        postal_code: 'M1R 3C3'
      )
      shipping_cost.destination(
        country: country,
        state: state,
        zip: zip
      )
      price = shipping_cost.fedex_ground
      (price) ? '%.2f' % price : price
    end
  end
  
  # Define the total cost
  def total_cost
    @validate_shipping = true
    return false if !printing_cost
    price = shipping_cost ? printing_cost.to_f + shipping_cost.to_f : printing_cost.to_f
    return '%.2f' % price.round(2)
  end
    
  private
  
    # Get the total pages number
    def num_pages
      num_bw_pages + num_color_pages
    end
end