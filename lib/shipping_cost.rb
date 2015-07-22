# Class to calculate shipping cost for book using FedEx API.
#
# Math to calculate packages numbers (email sent to Franck):
#   
#  Franck.
#
#  I have done a bit more research here and can see one issue right away. 
#  Using book count to calculate when a carton fills doesn't actually work that well, 
#  as the page counts in each book can vary dramatically (50-300 page range). 
#  What does work very well is using page count AND quantity together.
#
#  Our testing here showed that for a 200 page (100 sheets) book, 
#  we can get 40 into a carton. That basically means we can get 8,000 printed pages 
#  per carton (or 4,000 sheets of paper). I would suggest we keep a buffer in there 
#  and that we go with 6,000 printed pages per carton to be safe. 
#  (We would get fewer pages per carton with smaller page count books as there would be 
#  more spines and they take up more space in the carton)
#
#  So, the math would be page count x quantity until you hit 6,000 and THEN add another 
#  carton cost in for each additional 6,000 printed pages (or 3,000 sheets of paper).
#
#  Re Duplex printing; that simply refers to the fact that each sheet of paper is printed 
#  on both sides. Therefore; a book with 100 pages would only have 50 sheets of paper. 
#  This is vital when calculating the book weight. The actual page count must be divided 
#  by 2 to achieve an accurate weight.
#
#  This should lead us to much more accurate ship costs. Hope this 
#  helps. Let me know if any questions or any other info you may require.
#
#  Regards,
#
#  --
#  Bob Glustien <bob@humemediainc.com>
#  Director of Marketing 
#  HUME Media Inc.
#
#
# @example
#   shipping_cost = ShippingCost.new(book_pages_number: 50, quantity: 90)
#   shipping_cost.origin(
#     :country => 'US',
#     :state => 'CA',
#     :city => 'Beverly Hills',
#     :zip => '90210'
#   )
#   shipping_cost.destination(
#     :country => 'CA',
#     :province => 'ON',
#     :city => 'Ottawa',
#     :postal_code => 'K1P 1J1'
#   )
#   shipping_cost.fedex_ground
class ShippingCost
  include ActiveMerchant::Shipping

  # Weight per book for 1 spine and 2 covers in pounds
  CLASSIC_COVER_WEIGHT = 0.1
  HARD_COVER_WEIGHT = 0.75

  # Weight per sheet page in pounds
  SHEET_WEIGHT = 0.011

  # Carton weight for package containing 20 books maximum in pounds
  PACKAGE_WEIGHT = 2.5

  # Max number of sheets per package
  MAX_SHEETS_PER_PACKAGE = 3000

  # Fedex API credentials (production)
  FEDEX_API_KEY      = "v8O1ESA1JuO8D7Mh"
  FEDEX_API_ACCOUNT  = "138213137"
  FEDEX_API_METER    = "105488644"
  FEDEX_API_PASSWORD = "eT8D1xE28t8mKGwWbg10nx3uE"

  # Build the shipping cost calculator corresponding to the 
  # specified book type and book quantity
  #
  # @param options
  # @option options [Integer] :book_pages_number number of pages per book
  # @option options [Integer] :quantity the quantity of book to ship
  # @option options [Boolean] :hard_cover is the book has a hard cover (default to false)
  def initialize(options)
     @book_pages_number = options[:book_pages_number]
     @quantity = options[:quantity]
     @hard_cover = (options[:hard_cover].nil?) ? false : options[:hard_cover]
  end

  # Define the origin address of the shipping
  # see: https://github.com/Shopify/active_shipping/blob/master/lib/active_shipping/shipping/location.rb
  #
  # @param address [Hash] shipping address
  # @option address [String] :country United State 'US' or Canada 'CA'
  # @option address [String] :postal_code the postal code or zip code
  # @option address [String] :province the province or state (two letter format)
  # @option address [String] :city the city
  # @option address [String] :zip alias for `postal_code`
  # @option address [String] :state alias for `province`
  def origin(address)
    @origin = Location.new address
  end

  # Define the destination address of the shipping
  # see: https://github.com/Shopify/active_shipping/blob/master/lib/active_shipping/shipping/location.rb
  #
  # @param address [Hash] shipping address
  # @option address [String] :country United State 'US' or Canada 'CA'
  # @option address [String] :postal_code the postal code or zip code
  # @option address [String] :province the province or state (two letter format)
  # @option address [String] :city the city
  # @option address [String] :zip alias for `postal_code`
  # @option address [String] :state alias for `province`
  def destination(address)
    @destination = Location.new address
  end

  # Get the price using Fedex Ground shipping service
  def fedex_ground
    raise "No origin address specified" if !@origin
    raise "No destination address specified" if !@destination
    begin
      fedex = FedEx.new account: FEDEX_API_ACCOUNT, login: FEDEX_API_METER, key: FEDEX_API_KEY, password: FEDEX_API_PASSWORD
      response = fedex.find_rates(@origin, @destination, shipping_packages)
      price = nil
      response.rates.each do |rate| 
        price = rate.price if rate.service_name == "FedEx Ground"
      end
      cents_to_dollars price
    rescue
      return false
    end
  end

  private

  # Calculate the number of books per package based on 
  # the max number of sheets allowed per packages
  def books_per_package
    return (MAX_SHEETS_PER_PACKAGE / sheets_number).to_i
  end

  # Build 'active shipping' packages to calculate final price
  def shipping_packages
    packages = []
    books_to_ship = @quantity
    (1..packages_number).each do
      books = (books_to_ship > books_per_package) ? books_per_package : books_to_ship
      books_to_ship -= books_per_package if books_to_ship > books_per_package
      package_weight = pounds_to_grams(books * book_weight + PACKAGE_WEIGHT)
      packages << Package.new(package_weight, [])
    end
    return packages
  end

  # Calculate the weight for a single book in pounds
  def book_weight
    cover_weight + (sheets_number * SHEET_WEIGHT)
  end

  # Get the weight of the cover
  def cover_weight
    (@hard_cover) ? HARD_COVER_WEIGHT : CLASSIC_COVER_WEIGHT
  end

  # Calculate the number of sheets from the number of pages
  def sheets_number
    sheets = @book_pages_number / 2
    sheets += 1 if (@book_pages_number % 2) != 0
    return sheets
  end

  # Return the number of packages needed to ship the defined 
  # quantity of book
  def packages_number
    n = @quantity / books_per_package
    n += 1 if (@quantity % books_per_package) != 0
    return n
  end

  # Convert pounds into grams
  # 1 pound = 453.59237 grams
  def pounds_to_grams(pounds)
    pound_unit = 453.59237
    return pounds * pound_unit
  end

  # Convert cents to dollars
  def cents_to_dollars(cents)
    (cents.to_f / 100.0).round 2
  end
end