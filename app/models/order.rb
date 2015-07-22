class Order < ActiveRecord::Base
  attr_accessible :cookbook_id, :number_of_books, :bill_first_name, :bill_last_name, :bill_address,
    :bill_address2, :bill_city, :bill_zip, :bill_country, :bill_state, :bill_phone, :bill_email,
    :ship_first_name, :ship_last_name, :ship_address, :ship_address2, :ship_city, :ship_zip, 
    :ship_country, :ship_state, :ship_phone, :ship_email, :paid_on, :transaction_data, :generated_at, 
    :filename, :notes, :order_color_pages, :order_bw_pages, :order_printing_cost, 
    :order_shipping_cost, :delivery_time, :reorder_id, :version, :old_ship_phone, :old_bill_phone, 
    :user_id, :id, :created_on, :updated_on

  # Order::COUNTRIES => List of country codes
  include LocationCodes::Countries

  # Order::PROVINCES => List of province codes
  include LocationCodes::Provinces

  # Order::STATES => List of state codes
  include LocationCodes::States
  
  # -- Constants ------------------------------------------------------------
  
  MAX_NUMBER_OF_BOOKS = 200

  
  # -- Extensions -----------------------------------------------------------
  
  # include CustomLogger
  
  # -- Relationships --------------------------------------------------------
  
  belongs_to :cookbook
  belongs_to :user
  
  # -- Validations ----------------------------------------------------------
  
  validates_numericality_of :number_of_books, 
                            :only_integer => true,
                            :message => 'Please insert the number of books you wish to order.'

  validates_format_of :ship_phone, :bill_phone,
                      :with => /\A(\d{3}-\d{3}-\d{4})?\Z/, 
                      :message => 'Please enter you phone number with the format 123-456-7890'  

  validate :update_validation, :on => :update
  
  # -- Named Scopes ---------------------------------------------------------

  default_scope :order => 'paid_on DESC'
  scope :paid, :conditions => 'paid_on IS NOT NULL'

  # -- Class Methods --------------------------------------------------------

  # Get all the completed orders waiting for PDF file generation
  def self.pending
    Order.where('
      paid_on IS NOT NULL AND 
      generated_at IS NULL AND 
      reorder_id IS NULL
    ')
  end

  # CSV export
  def self.to_csv(orders, options = {})
    CSV.generate(options) do |csv|
      orders.each do |order| 
        order_book_binding = BookBinding.find_by_name(order.book_binding)
        heritage_margin = if (order.number_of_books > MAX_NUMBER_OF_BOOKS) || order.order_printing_cost.nil?
          "Unknown"
        else
          heritage_margin = PrintingCost.heritage_mark_up(
            order.order_printing_cost.to_f, 
            order.number_of_books, 
            (order_book_binding) ? order_book_binding.to_sym : nil
          )
        end
        csv << [
          order.id,
          order.paid_on,
          order.bill_first_name,
          order.bill_last_name,
          order.bill_email,
          order.is_pending? ? "Pending" : "Generated",
          order.num_pages,
          order.number_of_books,
          order.book_binding,
          order.order_printing_cost,
          order.order_shipping_cost,
          order.order_total_cost,
          heritage_margin
        ]
      end
    end
  end
  
  # -- Instance Methods -----------------------------------------------------

  # Check for Wire / Hard / Softcover if pagecount is below 80
  # Return true if everything is fine, false if the condition is met
  def check_cookbook_binding
    big_book_binding = [:wiro, :soft, :hard]
    !(big_book_binding.include?(cookbook.book_binding.to_sym) && cookbook.num_pages < 80)
  end

  # Return the total number of pages (black and white + color + cover)
  def num_pages
    if order_bw_pages && order_color_pages
      return 2 + order_bw_pages + order_color_pages
    end
  end

  # Is the order has been paid en need to be generated ?
  def is_pending?
    generated_at.nil? && !paid_on.nil?
  end
  
  def is_final
    @status='final'
  end
  
  def is_final?
    @status=='final'
  end

  def is_reorder?
    !reorder_id.nil?
  end

  def update_validation
    errors.add "number_of_books", "Our minimum order size is 4 books." if number_of_books.to_i < 4
    errors.add "ship_country", "Please select a country to ship your order to." if ship_country.empty?
    validates_country_and_zip "ship_country", "ship_zip"
    validates_country_and_state "ship_country", "ship_state"
    validate_final if is_final?
  end

  def validate_final
    validates_not_empty "bill_first_name", "bill_last_name", "bill_address", "bill_city", "bill_country"
    validates_country_and_zip "bill_country", "bill_zip"
    validates_country_and_state "bill_country", "bill_state"
    validates_not_empty "bill_phone", "bill_email"
    validates_not_empty "ship_first_name", "ship_last_name", "ship_address", "ship_city", "ship_country"
    validates_not_empty "ship_phone", "ship_email"

    # Validate that the Shipping address is not a P.O. Box
    validates_not_post_office_box :ship_address, :ship_address2
    
    # Validate that the shipping is returning a value
    if ship_country == 'United States' || ship_country == 'Canada'
      errors.add 'ship_zip', "Please check your zip/postal code as we're having trouble calculating shipping." unless shipping_cost
    end
  end
  
  def printing_cost
    if is_reorder?
      reorder_calculator.printing_cost
    else
      calculator.printing_cost
    end
  end
  
  def shipping_cost
    if is_reorder?
      reorder_calculator.shipping_cost
    else
      calculator.shipping_cost
    end
  end
  
  def total_cost
    if is_reorder?
      reorder_calculator.total_cost
    else
      calculator.total_cost
    end
  end

  # Calculate the total order cost from shipping and printing cost recorded in the order field
  # As opposite to `total_cost` function who ask the Fedex API about a price.
  def order_total_cost
    price = order_shipping_cost ? order_printing_cost.to_f + order_shipping_cost.to_f : order_printing_cost.to_f
    return '%.2f' % price.round(2)
  end
  
  def calculator
    @calculator ||= CookbookCostCalculator.new  :num_color_pages=>cookbook.num_color_pages, 
                                                :num_books=>number_of_books, 
                                                :num_bw_pages=>cookbook.num_bw_pages, 
                                                :country => country_code(ship_country), 
                                                :state => ship_state, 
                                                :zip => ship_zip,
                                                :binding => cookbook.book_binding.to_sym
  end

  # For re-order, use data from the order and not form the cookbook
  def reorder_calculator
    @calculator ||= CookbookCostCalculator.new  :num_color_pages=>order_color_pages, 
                                                :num_books=>number_of_books, 
                                                :num_bw_pages=>order_bw_pages, 
                                                :country => country_code(ship_country), 
                                                :state => ship_state, 
                                                :zip => ship_zip,
                                                :binding => BookBinding.find_by_name(book_binding).to_sym
  end
  
  def large_order?
    self.number_of_books >= MAX_NUMBER_OF_BOOKS ? true : false
  end
  
  def beanstream_cost
    unless transaction_data.blank?
      YAML.load(transaction_data)[:trnAmount].to_f 
    else
      0
    end
  rescue
    'COST LOOKUP FAILED'
  end
  
  # -- Class Methods --------------------------------------------------------
  
  def self.states_reverse
    states     = self.reverse_hash Order::STATES
    provinces   = self.reverse_hash Order::PROVINCES
    states.sort + ['------'] + provinces.sort + ['------'] + ['Outside U.S./Canada']
  end
  
private

  def validates_not_empty(*items)
    items.each do |item|
      errors.add item, "Please don't leave this field blank" if send(item).empty?
    end
  end

  def validates_country_and_zip(country, zip)
    errors.add zip, "Please use the format 55555." if send(country) == 'United States' && !Order.valid_postal_code?('US', send(zip))
    errors.add zip, "Please use the format M5M 5M5." if send(country) == 'Canada' && !Order.valid_postal_code?('CA', send(zip))
  end
  
  def validates_country_and_state(country, state)
    errors.add state, "Please choose a US state." if send(country) == 'United States' && !Order::STATES.has_key?(send(state))
    errors.add state, "Please choose a Canadian province" if send(country) == 'Canada' && !Order::PROVINCES.has_key?(send(state))
  end

  def validates_not_post_office_box(*attributes)
    attributes.each do |attribute|
      if self.send(attribute) =~ /P\.?O\.?\s?Box/i
        errors.add attribute, "We cannot ship to a PO Box."
      end
    end
  end

  def self.valid_postal_code?(country, code)
    regex = case country 
        when 'CA'
          /^([A-Z][0-9]){3,3}?$/ 
        when 'US'
          /^[0-9]{5,5}?([-]{0,1}[0-9]{4}){0,1}$/
        else 
          /\S/
        end
    return !code.to_s.upcase.gsub(/[\s-]/, '').match(regex).nil?
  end
  
  
  def self.reverse_hash(hash)
    returnVal = Hash.new
    hash.each do |key, value|
      returnVal[value] = key
    end
    returnVal.sort
  end
  
  def country_code(country)
    Order::COUNTRIES.find {|k,v| v == country}.first
  rescue
    false
  end


end
