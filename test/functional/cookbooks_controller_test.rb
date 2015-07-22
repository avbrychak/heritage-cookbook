require 'test_helper'

class CookbooksControllerTest < ActionController::TestCase
  
  test "should get redirected if not authenticated" do
    get :index
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "should get index if authenticated" do
    login_as users(:brian_smith)
    get :index
    assert_response :success
  end

  test "should load user cookbooks correctly" do
    user = users(:brian_smith)
    user_cookbooks_count             = users(:brian_smith).owned_cookbooks.count
    user_contributed_cookbooks_count = users(:brian_smith).contributed_cookbooks.count
    login_as_with_cookbook user, user.owned_cookbooks.last
    get :index
    assert assigns(:cookbooks).count             == user_cookbooks_count
    assert assigns(:contributed_cookbooks).count == user_contributed_cookbooks_count
  end

  test "should select a cookbook to work on" do
    user = users(:brian_smith)
    cookbook = user.owned_cookbooks.first
    selected_cookbook = user.owned_cookbooks[1]
    login_as_with_cookbook user, cookbook
    get :select, id: selected_cookbook.id
    assert_response :redirect
    assert_redirected_to templates_path
    assert session[:cookbook_id] == selected_cookbook.id
    assert flash[:alert].nil?
  end

  test "should not select a cookbook not owned or contributed by the current user" do
    user = users(:john_smith)
    login_as_with_cookbook user, user.owned_cookbooks.first
    get :select, id: users(:brian_smith).owned_cookbooks.first.id
    assert_response :redirect
    assert_redirected_to cookbooks_path
    assert_equal "Unable to select cookbook. Either it doesn't exist or you have no permission accessing it.", flash[:alert]
  end

  test "should alert an expired user it will not be able to work on its selected cookbook" do
    user = users(:will_smith)
    cookbook = user.owned_cookbooks.first
    login_as_with_cookbook user, user.owned_cookbooks.first
    get :select, id: cookbook.id
    assert_response :redirect
    assert_redirected_to templates_path
    assert session[:cookbook_id] == cookbook.id
    assert_equal "Because your membership has expired you can no longer work on your cookbooks.", flash[:alert]
  end

  test "should alert an user it will not be able to work on a contributed cookbook if its owner account has expired" do
    user = users(:brian_smith)
    cookbook = users(:will_smith).cookbooks.first
    login_as_with_cookbook user, user.owned_cookbooks.first
    get :select, id: cookbook.id
    assert_response :redirect
    assert_redirected_to templates_path
    assert session[:cookbook_id] == cookbook.id
    assert_equal "The owner of this cookbook's membership has expired. They will have to extend it for you to gain access to this cookbook.", flash[:alert]
  end

  test "should create a new cookbook for the user" do
    user = users(:brian_smith)
    login_as_with_cookbook user, user.owned_cookbooks.first
    assert_difference "user.owned_cookbooks.count", 1 do
      get :new
    end
    assert_response :redirect
    assert_redirected_to templates_path
    assert_equal "A new cookbook was created for you.", flash[:notice]
  end

  # Note: Cookbooks limit has been deprecated
  # test "should alert the user he cannot create any more cookbooks" do
  #   user = users(:john_smith)
  #   login_as_with_cookbook user, user.owned_cookbooks.first
  #   assert_difference "user.owned_cookbooks.count", 0 do
  #     get :new
  #   end
  #   assert_response :redirect
  #   assert_redirected_to cookbooks_path
  #   assert_equal "You cannot create any more cookbook projects", flash[:alert]
  # end

  test "an expired user cannot create any more cookbooks" do
    user = users(:will_smith)
    login_as_with_cookbook user, user.owned_cookbooks.first
    assert_difference "user.owned_cookbooks.count", 0 do
      get :new
    end
    assert_response :redirect
    assert_redirected_to upgrade_account_path(user)
  end

  test "get the page to edit cookbook title" do
    user = users(:brian_smith)
    login_as_with_cookbook user, user.owned_cookbooks.first
    get :edit_title, id: user.owned_cookbooks.first.id
    assert_response :success
  end

  test "should update the cookbook title" do
    user = users(:brian_smith)
    login_as_with_cookbook user, user.owned_cookbooks.first
    put :update_title, id: user.owned_cookbooks.first.id, cookbook: {title: "My new title"}
    assert_response :redirect
    assert_redirected_to templates_path
    assert_equal "Your Cookbook name has been changed!", flash[:notice]
    assert_equal "My new title", assigns(:cookbook).title
  end

  test "get the page to edit cookbook introduction" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    get :edit_introduction, id: cookbook.id
    assert_response :success
  end

  test "should update the introduction elements" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook user, cookbook
    xhr :put, :update_introduction, id: cookbook.id, cookbook: {
      intro_type: 1,
      center_introduction: true,
      intro_text: lorem * 4,
      intro_image_grayscale: false,
      # intro_image: fixture_file_upload("images/family-landscape.jpg", 'image/jpeg', :binary)
    }
    assert_response :success
    assert_equal "The introduction of your cookbook was saved.", flash[:notice]
    assert "family-landscape.jpg", assigns(:cookbook).intro_image.original_filename
  end

  test "should not being able to edit the introduction if no design was selected for this cookbook" do
    user = users(:brian_smith)
    cookbook = cookbooks(:brian_smith_second_cookbook)
    login_as_with_cookbook user, cookbook
    get :edit_introduction, id: cookbook.id
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal 'Sorry, You cannot do this action until you set the design', flash[:alert]
  end

  test "should not being able to edit the introduction if no cookbook is selected" do
    user = users(:brian_smith)
    login_as user
    get :edit_introduction, id: cookbooks(:brian_smith_first_cookbook).id
    assert_response :redirect
    assert_redirected_to cookbooks_path
    assert_equal "You must have selected a Cookbook project to work on first.", flash[:alert]
  end

  test "should reach the page to edit the cookbook attributes" do
    user = users(:brian_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    get :edit, id: cookbook
    assert_response :success
  end

  test "should update the cookbook attributes" do
    user = users(:brian_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    xhr :put, :update, id: cookbook, cookbook: {
      tag_line_1: "Hello There !",
      tag_line_2: "This is my best cookbook ever !",
      grayscale: 0,
      show_index: 1
    }
    assert_response :success
    assert_equal "Hello There !", assigns(:cookbook).tag_line_1
  end

  test "should signal the user if the cookbook cannot be updated and save valid fields" do
    user = users(:brian_smith)
    cookbook = user.owned_cookbooks.last
    login_as_with_cookbook user, cookbook
    xhr :put, :update, id: cookbook, cookbook: {
      tag_line_1: "Hello There! I must be saved!",
      tag_line_2: "This is my best cookbook ever !"*100,
      grayscale: 0,
      show_index: 1
    }
    assert_response :success
    assert assigns(:cookbook).errors.any?
    assert_equal "Hello There! I must be saved!", assigns(:cookbook).tag_line_1
  end

  test "should not being able to edit cookbook if not owner" do
    user = users(:brian_smith)
    cookbook = user.contributed_cookbooks.last
    login_as_with_cookbook user, cookbook
    xhr :put, :update, id: cookbook, cookbook: {
      tag_line_1: "Hello There !",
      tag_line_2: "This is my best cookbook ever !"*100,
      grayscale: 0,
      show_index: 1,
      # user_image: fixture_file_upload("images/family-landscape.jpg", 'image/jpeg', :binary)
    }
    assert_response :redirect
    assert_redirected_to sections_path
    assert_equal "As a Contributor you may only access the \"Recipes\" and \"Preview\" pages for the cookbook.", flash[:alert]
  end

  test "should preview a cookbook" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview, id: cookbook.id
    assert_response :success
  end

  test "should preview a cookbook cover" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview_cover, id: cookbook.id
    assert_response :success
  end

  test "should preview a cookbook title page and table of contents" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview_title_and_toc, id: cookbook.id
    assert_response :success
  end

  test "should preview a cookbook index" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview_index, id: cookbook.id
    assert_response :success
  end

  test "should preview a cookbook introduction" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview_introduction, id: cookbook.id
    assert_response :success
  end

  test "should check the current cookbook price" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :check_price, id: cookbook.id
    assert_response :success
  end
end
