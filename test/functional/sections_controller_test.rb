require 'test_helper'

class SectionsControllerTest < ActionController::TestCase

  test "should list all sections in the current cookbook" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    get :index
    assert_response :success
    assert cookbook.sections.count == assigns(:sections).count
  end

  test "should display the page to add a new section" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_second_cookbook)
    assert_difference "Section.count" do
      get :new
    end
    assert_response :success
  end

  test "should alert the user if the section is not valid" do
    cookbook = cookbooks(:brian_smith_second_cookbook)
    section = cookbook.sections.first
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :put, :update, id: section.id, section: {
      name: ""
    }
    assert_response :success
    assert assigns(:section).errors.any?
  end

  test "should alert the user if cookbook have max authorized number of sections" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    assert_no_difference "cookbook.sections.count" do
      post :new
    end
    assert_response :redirect
    assert_redirected_to sections_path
    assert_equal "You may only have #{Section::MAX_SECTIONS} sections. Try deleting a section first, or renaming an existing section.", flash[:alert]
  end

  test "should get the page to modify an existing section" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    login_as_with_cookbook users(:brian_smith), cookbook
    get :edit, id: section.id
    assert_response :success
    assert assigns(:section).id == section.id
  end

  test "should update an existing section" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :put, :update, id: section.id, section: {
      name: "Vegetables recipes"
    }
    assert_response :success
    assert assigns(:section).name == "Vegetables recipes"
  end

  test "should alert the user if the updated section is not valid" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :put, :update, id: section.id, section: {
      name: ""
    }
    assert_response :success
    assert assigns(:section).errors.any?
  end

  test "should remove an existing cookbook section" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    login_as_with_cookbook users(:brian_smith), cookbook
    assert_difference "cookbook.sections.count", -1 do
      delete :destroy, id: section.id
    end
    assert_response :redirect
    assert_redirected_to sections_path
    assert_equal "Section: #{section.name} was successfully removed", flash[:notice]
  end

  test "should render a section preview" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview, id: section
    assert_response :success
  end

  test "should not allow a contributor to manage sections" do
    contributor = users(:adam_smith)
    owner = users(:brian_smith)
    cookbook = owner.cookbooks.last
    section = cookbook.sections.first
    login_as_with_cookbook contributor, cookbook
    get :edit, id: section.id
    assert_response :redirect
    assert_redirected_to sections_path
    assert_equal "Sorry, but you are not allowed to manage sections.", flash[:alert]
  end

  test "should display a section content" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :show, id: section
    assert_response :success
  end
end
