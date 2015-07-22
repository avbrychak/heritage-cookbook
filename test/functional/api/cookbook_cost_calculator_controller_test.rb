require 'test_helper'

class Api::CookbookCostCalculatorControllerTest < ActionController::TestCase
  
  test "get shipping price" do
  	xhr :post, :printing, num_bw_pages: 29, num_color_pages: 13, num_books: 145, binding: 'plastic_coil'
  	assert_response :success
  end
end
