require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

  test "should get the order page" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    assert_difference "Order.count" do
      get :new
    end
    assert_response :success
    assert assigns(:cookbook).id == cookbook.id
    assert_not_nil assigns(:order).id
    assert assigns(:order).ship_country == user.country
    assert assigns(:order).bill_country == user.country
    assert assigns(:order).ship_state == user.state
    assert assigns(:order).bill_state == user.state
    assert assigns(:order).ship_zip == user.zip
    assert assigns(:order).bill_zip == user.zip
    assert assigns(:order).calculator.valid?
    assert assigns(:order).calculator.printing_cost
    assert assigns(:order).calculator.shipping_cost
    assert assigns(:order).calculator.total_cost
  end

  test "should update the current order" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    cost = order.calculator.total_cost
    xhr :put, :update, id: order.id, order: {
      number_of_books: 100,
      ship_country: order.ship_country,
      ship_state: order.ship_state,
      ship_zip: order.ship_zip
    }
    assert_response :success
    assert assigns(:order).calculator.total_cost.to_f > cost.to_f
  end

  test "should alert the user its order is not valid" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    xhr :put, :update, id: order.id, order: {
      number_of_books: 100,
      ship_country: 'Canada',
      ship_state: 'CA',
      ship_zip: order.ship_zip
    }
    assert_response :success
    assert assigns(:order).errors.any?
  end

  test "user must not be a contributor to create an order" do
    user = users(:adam_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    get :new
    assert_response :success
    assert_nil assigns(:order)
  end

  test "a design must be set to create an order" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_second_cookbook)
    login_as_with_cookbook user, cookbook
    get :new
    assert_redirected_to root_path
    assert_equal "Sorry, You cannot do this action until you set the design", flash[:alert]
  end

  test "the selected cookbook must have some content to create an order" do
    user = users(:john_smith)
    cookbook = cookbooks(:john_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    get :new
    assert_redirected_to sections_path
    assert_equal "Sorry, but you cannot order this cookbook until you add some content", flash[:alert]
  end

  test "user must be noticied to contact susan if it's an international order" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    xhr :put, :update, id: order.id, order: {
      number_of_books: 100,
      ship_country: "Other",
      ship_state: "France",
      ship_zip: "37000"
    }
    assert_response :success
    assert assigns(:order).ship_country == 'Other' 
    assert response.body =~ /Please contact us regarding International orders/
  end

  test "user must be notified if it's a large order" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    xhr :put, :update, id: order.id, order: {
      number_of_books: Order::MAX_NUMBER_OF_BOOKS+100,
      ship_country: order.ship_country,
      ship_state: order.ship_state,
      ship_zip: order.ship_zip
    }
    assert_response :success
    assert assigns(:order).number_of_books == Order::MAX_NUMBER_OF_BOOKS+100
    assert response.body =~ /Request a price quote/
  end

  test "user request a price quote" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    assert_difference 'ActionMailer::Base.deliveries.count' do
      get :ask_price_quote, id: order.id
    end
    assert_response :success
  end

  test "get the page to request a price quote" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    assert_difference 'ActionMailer::Base.deliveries.count' do
      get :ask_price_quote, id: order.id
    end
    assert_response :success
  end

  test "asking for price when cookbook have a binding not supporting its number of pages" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    get :notify_binding_problem, id: order.id
    assert_response :success
  end

  test "sould get the customer details page" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    get :edit_customer_details, id: order.id
    assert_response :success
  end

  test "should update the customer details" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    put :update_customer_details, id: order.id, order: {
      bill_first_name: order.bill_first_name,
      bill_last_name:  order.bill_last_name,
      bill_country:    order.bill_country,
      bill_address:    order.bill_address,
      bill_address2:   order.bill_address2,
      bill_city:       order.bill_city,
      bill_state:      order.bill_state,
      bill_zip:        order.bill_zip,
      bill_phone:      order.bill_phone,
      ship_first_name: "Adam",
      ship_last_name:  "Smith",
      ship_country:    order.ship_country,
      ship_address:    order.ship_address,
      ship_address2:   order.ship_address2,
      ship_city:       order.ship_city,
      ship_state:      order.ship_state,
      ship_zip:        order.ship_zip,
      ship_phone:      order.ship_phone,
      notes:           lorem,
      delivery_time:   lorem
    }
    assert_response :redirect
    assert_redirected_to confirm_order_path(order)
    assert assigns(:order).ship_first_name != order.ship_first_name
  end

  test "should get the order confirmation page" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    get :confirm, id: order.id
    assert_response :success
  end

  test "should get the approved order page if order is processed" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    assert_difference 'ActionMailer::Base.deliveries.count', 2 do
      get :approved, id: order.id , ref1: order.id, trnAmount: "40.00"
    end
    assert_response :success
    assert_not_nil assigns(:order).paid_on
    assert_not_nil assigns(:order).transaction_data
    assert_not_nil assigns(:order).order_color_pages
    assert_not_nil assigns(:order).order_bw_pages
    assert_not_nil assigns(:order).order_printing_cost
    assert_not_nil assigns(:order).order_shipping_cost
    assert assigns(:order).cookbook.is_locked_for_printing
    assert_equal "Thank you! Your order was completed successfully.", flash[:notice]
    assert assigns(:order).user.paid_orders_count > user.paid_orders_count
  end

  test "should be redirected to the order page if order is declined" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = cookbook.get_active_order
    get :declined, id: order.id, ref1: order.id
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "Your order was not processed. It was cancelled by the credit card processor. ", flash[:alert]
    assert_not_nil assigns(:order).transaction_data
  end

  test "should get the page to create a re-order" do
    user = users(:john_smith)
    cookbook = cookbooks(:john_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    order = orders(:john_smith_order_2)
    get :reorder, id: order.id
    assert_response :success
    assert_equal order.id, assigns(:old_order).id
    assert_equal order.id, assigns(:order).reorder_id
  end

  test "should update the current re-order" do
    user = users(:john_smith)
    cookbook = cookbooks(:john_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    reorder = cookbook.get_active_reorder 159
    cost = reorder.calculator.total_cost
    xhr :put, :update_reorder, id: reorder.id, order: {
      number_of_books: 166,
      ship_country: reorder.ship_country,
      ship_state: reorder.ship_state,
      ship_zip: reorder.ship_zip
    }
    assert_response :success
    assert assigns(:order).calculator.total_cost.to_f > cost.to_f
  end

  test "should access a guest order page" do
    user = users(:john_smith)
    cookbook = cookbooks(:john_smith_first_cookbook)
    order = orders(:john_smith_order_2)
    login_as_with_cookbook user, cookbook
    xhr :delete, :guest, id: order.id
    assert_response :success
    assert assigns(:order).id != order.id
  end
end