# Class to retrieve printing cost for book element based on book quantity and binding type.
#
# @example Get the price for a color page for 40 books with Hard binding
#   pricing = PrintingCost.new binding: :hard, quantity: 40
#   price_per_color_page = pricing.color_page
class PrintingCost

  # Pricing table for the 6x9 Wiro binding
  BINDING_6X9WIRO = {
    1..19    => [0.0600, 0.2700, 1.0000, 0.0000, 2.5000, 0.0000, 0.0000, 0.0000, 0.0000, 4.5000,  0.0000, 0.175],
    20..39   => [0.0500, 0.2500, 0.9000, 0.0000, 2.5000, 0.0000, 0.0000, 0.0000, 0.0000, 9.0000,  0.0000, 0.175],
    40..59   => [0.0450, 0.2000, 0.8500, 0.0000, 2.4500, 0.0000, 0.0000, 0.0000, 0.0000, 13.5000, 0.0000, 0.175],
    60..79   => [0.0420, 0.1800, 0.8000, 0.0000, 2.4500, 0.0000, 0.0000, 0.0000, 0.0000, 19.0000, 0.0000, 0.175],
    80..99   => [0.0400, 0.1500, 0.7700, 0.0000, 2.4500, 0.0000, 0.0000, 0.0000, 0.0000, 23.5000, 0.0000, 0.175],
    100..199 => [0.0380, 0.1200, 0.7500, 0.0000, 2.3500, 0.0000, 0.0000, 0.0000, 0.0000, 30.0000, 0.0000, 0.175],
    200..299 => [0.0370, 0.1000, 0.7400, 0.0000, 2.3000, 0.0000, 0.0000, 0.0000, 0.0000, 40.0000, 80.0000, 0.130],
    300..399 => [0.0360, 0.0900, 0.7300, 0.0000, 2.2500, 0.0000, 0.0000, 0.0000, 0.0000, 50.0000, 80.0000, 0.130]
  }

  # Pricing table for the 6x9 Plastic Coil binding
  BINDING_6X9PLASTICCOIL = {
    1..19    => [0.0600, 0.2700, 1.0000, 0.0000, 2.3500, 0.0000, 0.0000, 0.0000, 0.0000, 4.5000,  0.0000, 0.175],
    20..39   => [0.0500, 0.2500, 0.9000, 0.0000, 1.8500, 0.0000, 0.0000, 0.0000, 0.0000, 9.0000,  0.0000, 0.175],
    40..59   => [0.0450, 0.2000, 0.8500, 0.0000, 1.7000, 0.0000, 0.0000, 0.0000, 0.0000, 13.5000, 0.0000, 0.175],
    60..79   => [0.0420, 0.1800, 0.8000, 0.0000, 1.5000, 0.0000, 0.0000, 0.0000, 0.0000, 19.0000, 0.0000, 0.175],
    80..99   => [0.0400, 0.1500, 0.7700, 0.0000, 1.4000, 0.0000, 0.0000, 0.0000, 0.0000, 23.5000, 0.0000, 0.175],
    100..199 => [0.0380, 0.1200, 0.7500, 0.0000, 1.3000, 0.0000, 0.0000, 0.0000, 0.0000, 30.0000, 0.0000, 0.175],
    200..299 => [0.0370, 0.1000, 0.7400, 0.0000, 1.2000, 0.0000, 0.0000, 0.0000, 0.0000, 40.0000, 80.0000, 0.130],
    300..399 => [0.0360, 0.0900, 0.7300, 0.0000, 1.1700, 0.0000, 0.0000, 0.0000, 0.0000, 50.0000, 80.0000, 0.130]
  }

  # Pricing table for the 7x10 Soft binding
  BINDING_7X10SOFT = {
    1..19    => [0.0672, 0.2600, 1.0000, 2.0000, 0.6700, 0.0000, 0.0000, 0.0000, 0.0000, 4.5000,  0.0000, 0.175],
    20..39   => [0.0560, 0.2500, 0.9000, 1.5000, 0.3700, 0.0000, 0.0000, 0.0000, 0.0000, 9.0000,  0.0000, 0.175],
    40..59   => [0.0500, 0.2300, 0.8500, 1.3500, 0.3700, 0.0000, 0.0000, 0.0000, 0.0000, 13.5000, 0.0000, 0.175],
    60..79   => [0.0470, 0.2000, 0.8000, 1.2500, 0.3700, 0.0000, 0.0000, 0.0000, 0.0000, 19.0000, 0.0000, 0.175],
    80..99   => [0.0450, 0.1700, 0.7700, 1.1000, 0.3700, 0.0000, 0.0000, 0.0000, 0.0000, 23.5000, 0.0000, 0.175],
    100..199 => [0.0430, 0.1400, 0.7500, 1.0000, 0.3200, 0.0000, 0.0000, 0.0000, 0.0000, 30.0000, 0.0000, 0.175],
    200..299 => [0.0410, 0.1200, 0.7400, 0.9000, 0.2900, 0.0000, 0.0000, 0.0000, 0.0000, 40.0000, 80.0000, 0.130],
    300..399 => [0.0400, 0.1000, 0.7300, 0.8000, 0.2800, 0.0000, 0.0000, 0.0000, 0.0000, 50.0000, 80.0000, 0.130]
  }

  # Pricing table for the 7x10 Hard binding
  BINDING_7x10HARD = {
    1..19    => [0.0672, 0.2600, 0.0000, 2.0000, 0.6700, 0.7000, 0.1000, 15.0000, 60.0000,  4.5000,  0.0000, 0.175],
    20..39   => [0.0560, 0.2500, 0.0000, 1.5000, 0.3700, 0.6500, 0.1000, 15.0000, 60.0000,  9.0000,  0.0000, 0.175],
    40..59   => [0.0500, 0.2300, 0.0000, 1.3500, 0.3700, 0.6500, 0.1000, 13.0000, 200.0000,  13.5000, 0.0000, 0.175],
    60..79   => [0.0470, 0.2000, 0.0000, 1.2500, 0.3700, 0.6500, 0.1000, 13.0000, 200.0000,  19.0000, 0.0000, 0.175],
    80..99   => [0.0450, 0.1700, 0.0000, 1.1000, 0.3700, 0.6000, 0.1000, 12.0000, 200.0000,  23.5000, 0.0000, 0.175],
    100..199 => [0.0430, 0.1400, 0.0000, 1.0000, 0.3200, 0.6000, 0.1000, 10.0000, 200.0000, 30.0000, 0.0000, 0.175],
    200..299 => [0.0410, 0.1200, 0.0000, 0.9000, 0.2900, 0.6000, 0.1000, 4.7000, 200.0000, 40.0000, 80.0000, 0.130],
    300..399 => [0.0400, 0.1000, 0.0000, 0.8000, 0.2800, 0.6000, 0.1000, 4.4800, 200.0000, 50.0000, 80.0000, 0.130]
  }
  
  # Find the pricing details corresponding to the selected binding and book quantity.
  #
  # @param options
  # @option options [Symbol] :binding the type of book binding, supported: :wiro, :plastic_coil, :soft and :hard
  # @option options [Integer] :quantity the quantity of book
  def initialize(options={})
    @binding = options[:binding] || :plastic_coil
    @quantity = options[:quantity] || 1

    find_pricing_details
  end

  # Price per B&W page
  def black_and_white_page
    @pricing_table[0]
  end

  # Price per color page
  def color_page
    @pricing_table[1]
  end

  # Binding price per book
  def binding
    @pricing_table[2]
  end

  # Cover price per book - ink
  def cover_ink
    @pricing_table[3]
  end

  # Cover price per book - lam
  def cover_lam
    @pricing_table[4]
  end

  # Prebind BKS unstrimmed (blank 100# paper)
  # Only user for the hard cover binding
  # Price per book
  def prebind_papers
    @pricing_table[5]
  end

  # End paperw (blank 100# paper WHT/BK)
  # Only user for the hard cover binding
  # Price per book
  def end_papers
    @pricing_table[6]
  end

  # Case bind 80PT board BK
  # Only user for the hard cover binding
  # Price per book
  def case_binding
    @pricing_table[7]
  end

  # Outsourced bindery cost
  # Only user for the hard cover binding
  def outsourced_bindery
    @pricing_table[8]
  end

  # Order fullfillment
  def order_fullfillment
    @pricing_table[9]
  end

  # Book sample before printing
  def book_sample
    @pricing_table[10]
  end

  # Percentage of price increase on the total 
  # printing cost to be added for heritage.
  def heritage_mark_up
    @pricing_table[11]
  end

  # Calculate the Heritage mark up from the given printing cost
  def self.heritage_mark_up(printing_cost, quantity, binding)
    printing = PrintingCost.new(binding: binding, quantity: quantity)
    percentage = printing.heritage_mark_up
    original_cost = printing_cost / (1+percentage)
    markup = printing_cost - original_cost
    return '%.2f' % markup.round(2)
  end

  private

  # Retrieve the pricing table corresponding to the selected binding
  def get_binding_pricing
    case @binding
    when :wiro
      return BINDING_6X9WIRO
    when :plastic_coil
      return BINDING_6X9PLASTICCOIL
    when :soft
      return BINDING_7X10SOFT
    when :hard
      return BINDING_7x10HARD
    end
  end

  # Find the pricing details corresponding to the selected binding and selected quantity
  def find_pricing_details
    pricing = get_binding_pricing
    pricing.each do |range, pricing_details|
      @pricing_table = pricing_details if range === @quantity
    end
  end
end
