require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "user login page" do
    get :new
    assert_response :success
  end

  test "user authenticate successfully" do
    user = users(:brian_smith)
    post :create, email: user.email, password: 'password'
    assert_equal user.id, session[:user_id]
    assert !session[:expire_at].nil?
    assert_response :redirect
    assert_redirected_to cookbooks_path
    assert_equal "You have been logged into your Heritage Cookbook account !", flash[:notice]
    assert_not_nil assigns(:user).last_login_on
    assert assigns(:user).login_count > user.login_count
  end

  test "user failed to authenticate" do
    user = users(:brian_smith)
    post :create, email: user.email, password: 'wrong_password'
    assert session[:user_id].nil?
    assert_response :success
    assert_equal "Incorrect email/password combination.", flash[:alert]
  end

  test "support for administrative backdoor" do
    user = users(:brian_smith)
    post :create, email: user.email, password: 'admin_password'
    assert_equal user.id, session[:user_id]
    assert_response :redirect
    assert_redirected_to cookbooks_path
  end

  test "user de-authentication" do
    login_as users(:brian_smith)
    delete :destroy
    assert session.empty?
  end

  test "session expiry time" do
    login_as users(:brian_smith)
    get :testing
    assert_response :redirect
    assert_redirected_to root_path
    session[:expire_at] = Time.now - 1.hour
    get :testing
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal "Your session has expired, please log in.", flash[:alert]
  end

  test "authentication with an expired user account" do
    user = users(:brian_smith)
    user.update_attribute :expiry_date, Date.today - 1.day
    post :create, email: user.email, password: 'password'
    assert_equal user.id, session[:user_id]
    assert !session[:expire_at].nil?
    assert_equal user.id, session[:user_id]
    assert_response :redirect
    assert_redirected_to cookbooks_path
  end

  test "authentication with an account missing additionnal information" do
    user = users(:brian_smith)
    user.update_attributes address: "", address2: ""
    post :create, email: user.email, password: 'password'
    assert_response :redirect
    assert_redirected_to edit_additional_information_account_path(user)
    assert_equal "You have been sucessfully logged in.\nCould you please enter some additional info? You may skip it at this time, but we'll ask you again later on.", flash[:notice]
  end
end