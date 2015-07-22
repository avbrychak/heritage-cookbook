require 'test_helper'

class ContributorsControllerTest < ActionController::TestCase
  
  test "should access the contributors page" do
    user = users(:brian_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    get :index
    assert_response :success
    assert assigns(:contributors).count == cookbook.contributors.count
  end

  test "should invite an existing user as a contributor" do
    user = users(:brian_smith)
    contributor = users(:john_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    assert_difference 'ActionMailer::Base.deliveries.count' do
      post :create, user: {
        first_name: contributor.first_name,
        last_name: contributor.last_name,
        email: contributor.email,
        contributor_message: "Allez viens! Viens ! On est bien !"
      }
    end
    assert_response :redirect
    assert_redirected_to contributors_path
    assert_not_nil assigns(:contributor)
    assert_not_nil assigns(:authorship)
    assert_equal "#{contributor.name} was added to your list of contributors.", flash[:notice]
    assert_equal "Allez viens! Viens ! On est bien !", assigns(:contributor_message)
    assert_equal contributor.id, assigns(:authorship).user.id
    assert_equal cookbook.id, assigns(:authorship).cookbook.id
    assert_equal 2, assigns(:authorship).role
  end

  test "should invite a non-existing user as a contributor" do
    user = users(:brian_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    assert_difference 'ActionMailer::Base.deliveries.count' do
      assert_difference 'User.count' do
        post :create, user: {
          first_name: "Cooky",
          last_name: "Smith",
          email: "cooky.smith@heritage.com",
          contributor_message: "Allez viens! Viens ! On est bien !"
        }
      end
    end
    assert_response :redirect
    assert_redirected_to contributors_path
    assert_not_nil assigns(:contributor)
    assert_not_nil assigns(:authorship)
    assert_equal "Cooky Smith was added to your list of contributors.", flash[:notice]
    assert_equal "Allez viens! Viens ! On est bien !", assigns(:contributor).contributor_message
    assert_equal "Allez viens! Viens ! On est bien !", assigns(:contributor_message)
    assert_equal "Cooky", assigns(:authorship).user.first_name
    assert_equal cookbook.id, assigns(:authorship).cookbook.id
    assert_equal 2, assigns(:authorship).role
  end

  test "should not let the user invite himself as a contributor" do
    user = users(:brian_smith)
    contributor = user
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    assert_difference 'ActionMailer::Base.deliveries.count', 0 do
      post :create, user: {
        first_name: contributor.first_name,
        last_name: contributor.last_name,
        email: contributor.email,
        contributor_message: "Allez viens! Viens ! On est bien !"
      }
    end
    assert_response :redirect
    assert_redirected_to contributors_path
    assert_nil assigns(:contributor)
    assert_nil assigns(:authorship)
    assert_equal "You cannot add yourself as a contributor", flash[:alert]
  end

  test "should not let the user add an existing contributor" do
    user = users(:john_smith)
    contributor = users(:brian_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    assert_difference 'ActionMailer::Base.deliveries.count', 0 do
      post :create, user: {
        first_name: contributor.first_name,
        last_name: contributor.last_name,
        email: contributor.email,
        contributor_message: "Allez viens! Viens ! On est bien !"
      }
    end
    assert_response :redirect
    assert_redirected_to contributors_path
    assert_equal "This contributor is already on your list", flash[:alert]
  end

  test "should resend the invitation email for a contributor (existing user)" do
    user = users(:john_smith)
    contributor = users(:brian_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    assert_difference 'ActionMailer::Base.deliveries.count' do
      get :resend_invite, id: contributor.id
    end
    assert_response :redirect
    assert_redirected_to contributors_path
    assert_not_nil assigns(:contributor)
    assert_equal "Invitational Email to #{contributor.email} was resent.", flash[:notice]
  end

  test "should resend the invitation email for a contributor (new user)" do
    user = users(:brian_smith)
    contributor = users(:adam_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    assert_difference 'ActionMailer::Base.deliveries.count' do
      get :resend_invite, id: contributor.id
    end
    assert_response :redirect
    assert_redirected_to contributors_path
    assert_not_nil assigns(:contributor)
    assert_equal "Invitational Email to #{contributor.email} was resent.", flash[:notice]
  end

  test "should remove a contributor" do
    user = users(:brian_smith)
    contributor = users(:adam_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    assert_difference 'Authorship.count', -1 do
      get :destroy, id: contributor.id
    end
    assert_response :redirect
    assert_redirected_to contributors_path
    assert_equal "That contributor was removed from your contributor list", flash[:notice]
  end
end
