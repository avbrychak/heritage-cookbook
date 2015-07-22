require 'test_helper'

class Admin::OrdersControllerTest < ActionController::TestCase
  test "should get new connected as admin" do
    login_as users(:etienne_garnier)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    get :new, cookbook_id: cookbook.id
    assert_response :success
    assert_equal cookbook.id, assigns(:cookbook).id
    assert_not_nil assigns(:order)
  end

  test "should register an order as admin" do
    login_as users(:etienne_garnier)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    order = cookbook.get_active_order
    assert_difference "Order.where('paid_on IS NOT NULL AND generated_at IS NULL AND reorder_id IS NULL').count" do
      put :update, id: order.id, order: {number_of_books: 51}
    end
    assert_response :redirect
    assert_equal "OFFLINE", assigns(:order).transaction_data["trnAmount"]
    assert_equal cookbook.num_color_pages, assigns(:order).order_color_pages
    assert_equal cookbook.num_bw_pages, assigns(:order).order_bw_pages
    assert_equal cookbook.title, assigns(:order).cookbook_title
    assert_equal cookbook.book_binding.name, assigns(:order).book_binding
  end

end
