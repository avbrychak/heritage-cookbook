require 'test_helper'

class TemplatesControllerTest < ActionController::TestCase

  test "should be authenticated to access templates list" do
    get :index
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal "Your session has expired, please log in.", flash[:alert]
  end

  test "should have a cookbook select to access templates list" do
    user = users(:brian_smith)
    login_as user
    get :index
    assert_response :redirect
    assert_redirected_to cookbooks_path
    assert_equal "You must have selected a Cookbook project to work on first.", flash[:alert]
  end

  test "cookbook should not be locked to access the templates list" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_third_cookbook)
    login_as_with_cookbook user, cookbook
    get :index
    assert_response :redirect
    assert_redirected_to cookbooks_path
    assert_equal "This cookbook is locked and cannot be edited until the file has been sent to the printer", flash[:alert]
  end

  test "should have a non-expired account to access the template list" do
    user = users(:will_smith)
    login_as_with_cookbook user, user.cookbooks.last
    get :index
    assert_response :redirect
    assert_redirected_to upgrade_account_path(user)
  end
  
  test "should get template list" do
    user = users(:brian_smith)
    cookbook = user.cookbooks.last
    login_as_with_cookbook user, cookbook
    get :index
    assert_response :success
    assert assigns(:current_template_id) == cookbook.template.id
    assert assigns(:templates) == Template.all
  end

  test "should update the template for the current cookbook" do
    user = users(:brian_smith)
    cookbook = user.cookbooks.last
    new_template = templates(:template_3)
    login_as_with_cookbook user, cookbook
    get :select, id: new_template.id
    assert_response :redirect
    assert_redirected_to edit_cookbook_path(cookbook)
    assert_equal "Your design template is set", flash[:notice]
    assert assigns(:cookbook).template.id == new_template.id
  end

  test "should do nothing with a bad template id" do
    user = users(:brian_smith)
    cookbook = user.cookbooks.last
    login_as_with_cookbook user, cookbook
    get :select, id: 130
    assert_response :redirect
    assert_redirected_to templates_path
    assert_nil flash[:notice]
    assert assigns(:cookbook).template.id == cookbook.template.id
  end
end
