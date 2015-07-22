require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  
  test "should not being able to access the admin panel if not authenticated" do
    get :index
    assert_redirected_to login_path
  end

  test "should not being able to access the admin panel if not admin" do
    login_as users(:john_smith)
  	get :index
    assert_redirected_to root_path
  end

  test "should being able to access the admin panel if connected as admin" do
    login_as users(:etienne_garnier)
  	get :index
    assert_response :success
  end

end
