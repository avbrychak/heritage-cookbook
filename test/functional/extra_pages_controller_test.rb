require 'test_helper'

class ExtraPagesControllerTest < ActionController::TestCase

  test "should create a new extra page" do
    user = users(:brian_smith)
    login_as_with_cookbook user, cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    assert_difference "section.extra_pages.count" do
      get :new, section_id: section.id
    end
    assert_response :success
    assert_equal "My extra page was added to the #{section.name} as an extra page", flash[:notice]
    assert assigns(:extra_page).user.id == user.id
  end

  test "should get the page to edit an existing extra page" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    extra_page = section.extra_pages.first
    get :edit, section_id: section.id, id: extra_page.id
    assert_response :success
  end

  test "should update an existing extra page" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    extra_page = section.extra_pages.first
    xhr :put, :update, section_id: section.id, id: extra_page.id, extra_page: {
      name: "New name",
      text: extra_page.text,
      index_as_recipe: extra_page.index_as_recipe
    }
    assert_response :success
    assert assigns(:extra_page).name != extra_page.name
  end

  test "should alert the user updating a non valid extra page and save valid fields" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    extra_page = section.extra_pages.first
    xhr :put, :update, section_id: section.id, id: extra_page.id, extra_page: {
      name: "",
      text: "my new text",
      index_as_recipe: extra_page.index_as_recipe
    }
    assert_response :success
    assert assigns(:extra_page).errors.any?
    assert_equal "my new text", assigns(:extra_page).text
  end

  test "should remove an extra page" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    extra_page = section.extra_pages.first
    assert_difference "section.extra_pages.count", -1 do
      delete :destroy, section_id: section.id, id: extra_page.id
    end
    assert_response :redirect
    assert_redirected_to sections_path
    assert_equal "#{extra_page.name} was deleted from #{section.name}", flash[:notice]
  end

  test "should not allow a contributor to edit another user extra page" do
    login_as_with_cookbook users(:adam_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    extra_page = section.extra_pages.first
    get :edit, section_id: section.id, id: extra_page.id
    assert_response :redirect
    assert_redirected_to sections_path
    assert_equal "You are not allowed to edit this extra page.", flash[:alert]
  end

  test "should allow the cookbook owner to edit a contributed extra page" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    extra_page = extra_pages(:long_text_extra_page)
    get :edit, section_id: section.id, id: extra_page.id
    assert_response :success
  end

  test "should render an extra page preview" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    extra_page = section.extra_pages.first
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview, section_id: section.id, id: extra_page.id
    assert_response :success
  end
end