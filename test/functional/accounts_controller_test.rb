require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  test "should get signup page" do
    get :new
    assert_response :success
  end

  test "should create an account with a free plan" do
    assert_difference "User.count", 1 do
      post :create, user: {
        plan_id: plans(:one_month_free_trial).id,
        first_name: "John",
        last_name: "Smith",
        email: "john.smith@domain.tld",
        email_confirmation: "john.smith@domain.tld",
        password: "password",
        password_confirmation: "password",
        how_heard: "Friend",
        cookbook_type: "Familly Cookbook",
        address: "123, Fake St",
        address2: "",
        city: "San Francisco", 
        state: "Claifornia",
        zip: 94102,
        country: "United States",
        phone: "555-555-5555",
        newsletter: 1,
        terms_of_service: 1
      }
      assert_response :redirect
      assert_redirected_to root_path
      assert_equal "Congratulations, your Heritage Cookbook account has been created!", flash[:notice]
    end
  end

  test "should alert the user when required field are missing" do
    assert_difference "User.count", 0 do
      post :create, user: {
        plan_id: plans(:one_month_free_trial).id,
        last_name: "Smith",
        email: "john.smith@domain.tld",
        email_confirmation: "john.smith@domain.tld",
        password: "password",
        password_confirmation: "password",
        how_heard: "Friend",
        cookbook_type: "Familly Cookbook",
        address: "123, Fake St",
        address2: "",
        city: "San Francisco", 
        state: "Claifornia",
        zip: 94102,
        country: "United States",
        phone: "555-555-5555",
        newsletter: 1
      }
      assert_response :success
      assert assigns(:user).errors.include? :first_name
    end
  end

  test "should create the user with a paid plan and redirect him to account upgrade page" do
    assert_difference "User.count", 1 do
      assert_difference 'ActionMailer::Base.deliveries.count' do
        post :create, user: {
          plan_id: plans(:one_year_membership).id,
          first_name: "John",
          last_name: "Smith",
          email: "john.smith@domain.tld",
          email_confirmation: "john.smith@domain.tld",
          password: "password",
          password_confirmation: "password",
          how_heard: "Friend",
          cookbook_type: "Familly Cookbook",
          address: "123, Fake St",
          address2: "",
          city: "San Francisco", 
          state: "Claifornia",
          zip: 94102,
          country: "United States",
          phone: "555-555-5555",
          newsletter: 1,
          terms_of_service: 1
        }
      end
    end
    assert_response :redirect
    assert_redirected_to upgrade_account_path(assigns(:user), plan_id: plans(:one_year_membership).id)
    assert_equal "Congratulations, your Heritage Cookbook account has been created!", flash[:notice]
  end
  
  test "should be authenticated" do
    get :upgrade, id: users(:brian_smith).id
    assert_response :redirect
  end

  test "should the account upgrade page" do
    user = users(:brian_smith)
    login_as user
    get :upgrade, id: user.id
    assert_response :success
  end

  test "should get the account informations edit page" do
    user = users(:brian_smith)
    login_as user
    get :edit, id: user.id
    assert_response :success
  end

  test "should update the account informations" do
    user = users(:brian_smith)
    login_as user
    put :update, id: user.id, user: {
      first_name: user.first_name,
      last_name: user.last_name,
      email: 'family@smith.com',
      email_confirmation: 'family@smith.com',
      address: user.address,
      address2: user.address2,
      city: user.city,
      state: user.state,
      zip: user.zip,
      country: user.country,
      phone: user.phone
    }
    assert_response :redirect
    assert_redirected_to edit_account_path(user)
    assert_equal "Your account information was successfully updated.", flash[:notice]
    assert assigns(:user).errors.empty?
    assert_equal 'family@smith.com', assigns(:user).email
  end

  test "should alert on error when updating the account informations" do
    user = users(:brian_smith)
    login_as user
    put :update, id: user.id, user: {
      first_name: user.first_name,
      last_name: user.last_name,
      email: 'family@smith.com',
      email_confirmation: 'wrong@mail.tld',
      address: user.address,
      address2: user.address2,
      city: user.city,
      state: user.state,
      zip: user.zip,
      country: user.country,
      phone: user.phone,
      newsletter: user.newsletter
    }
    assert_response :success
    assert assigns(:user).errors.any?
  end

  test "should get the password edit page" do
    user = users(:brian_smith)
    login_as user
    get :edit_password, id: user.id
    assert_response :success
  end

  test "should update the user password" do
    user = users(:brian_smith)
    login_as user
    put :update_password, id: user.id, user: {
      old_password: 'password',
      password: 'new_password',
      password_confirmation: 'new_password'
    }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal "Your password was successfully changed. Please login with your new password to verify it worked.\nIf you have a problem, you can always get a new password with the \"Forgot your password\" link", flash[:notice]
    assert assigns(:user).authenticate 'new_password'
  end

  test "should alert the user when trying to update the password with a bad old password" do
    user = users(:brian_smith)
    login_as user
    put :update_password, id: user.id, user: {
      old_password: 'bad_password',
      password: 'new_password',
      password_confirm: 'new_password'
    }
    assert_response :success
    assert assigns(:user).errors.any?
    assert !assigns(:user).authenticate('new_password')
  end

  test "should alert the user when trying to update the password with bad confirmation entry" do
    user = users(:brian_smith)
    login_as user
    put :update_password, id: user.id, user: {
      old_password: 'password',
      password: 'new_password',
      password_confirmation: 'another_password'
    }
    assert_response :success
    assert assigns(:user).errors.any?
    assert !assigns(:user).authenticate('new_password')
  end

  test "should get the user additionnal information page" do
    user = users(:brian_smith)
    login_as user
    get :edit_additional_information, id: user.id
    assert_response :success
  end

  test "should update the user additionnal information page" do
    user = users(:brian_smith)
    user.update_attributes address: "", address2: ""
    login_as user
    put :update_additional_information, id: user.id, user: {
      address: "12, Fake St",
      address2: "",
      city: user.city,
      state: user.state,
      zip: user.zip,
      country: user.country,
      phone: user.phone,
      newsletter: user.newsletter
    }
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "12, Fake St", assigns(:user).address
    assert_equal "Thank you for filling out the additional information.", flash[:notice]
  end

  test "should notify the user when it forget missing additional information" do
    user = users(:brian_smith)
    user.update_attributes address: "", address2: "", city: ""
    login_as user
    put :update_additional_information, id: user.id, user: {
      address: "",
      address2: "",
      city: "San Francisco",
      state: user.state,
      zip: user.zip,
      country: user.country,
      phone: user.phone,
      newsletter: user.newsletter
    }
    assert_response :success
    assert assigns(:user).errors.any?
  end

  test "should get the account membership upgrade page" do
    user = users(:brian_smith)
    login_as user
    get :upgrade, id: user.id
    assert_response :success
  end

  test "should get the account membership upgrade page with a plan id specified in the page" do
    user = users(:brian_smith)
    login_as user
    get :upgrade, id: user.id, plan_id: plans(:one_year_membership).id
    assert_response :success
  end

  test "should process payment for account upgrade" do
    user = users(:brian_smith)
    login_as user
    get :process_payment, id: user.id, plan: plans(:one_year_membership).id
    assert_response :redirect
  end

  test "should figure out if payment has been successfully executed" do
    user = users(:brian_smith)
    old_expiry_date = user.expiry_date
    login_as user
    session[:purchased_plan_id] = plans(:one_year_membership).id
    assert_difference 'ActionMailer::Base.deliveries.count' do
      get :payment_processed, id: user.id, token: 12345, PayerID: 12345
    end
    assert_response :redirect
    assert_redirected_to root_path
    assert old_expiry_date < assigns(:user).expiry_date
  end

  test "should get the user password recovery page" do
    get :recover_password
    assert_response :success
  end

  test "should recover the user password" do
    user = users(:brian_smith)
    assert_difference 'ActionMailer::Base.deliveries.count' do
      post :new_password, user: {email: user.email}
    end
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal "A new password has been generated for you, and emailed to the email address you entered.", flash[:notice]
  end

  test "should signal the user its email do not exist when trying to recover password" do
    post :new_password, user: {email: "idontexist@unknowdomain.tld"}
    assert_response :success
    assert assigns(:user).errors.include? :email
  end

end
