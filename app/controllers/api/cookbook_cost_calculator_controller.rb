class Api::CookbookCostCalculatorController < ApplicationController
  respond_to :json

  after_filter :set_access_control_headers
  skip_before_filter :verify_authenticity_token

  def printing
    calculator = CookbookCostCalculator.new(
      num_bw_pages: params[:num_bw_pages].to_i, 
      num_color_pages: params[:num_color_pages].to_i, 
      num_books: params[:num_books].to_i, 
      binding: params[:binding].to_sym
    )
    price = calculator.printing_cost
    render json: {price: price}
  end

  private 

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = WORDPRESS_URL
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Allow-Credentials'] = "true"
  end
end
