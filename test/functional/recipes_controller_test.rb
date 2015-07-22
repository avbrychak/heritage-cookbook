require 'test_helper'

class RecipesControllerTest < ActionController::TestCase

  test "should get the page to edit a recipe" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    recipe = sections(:appetizers).recipes.first
    get :edit, section_id: section.id, id: recipe.id
    assert_response :success
    assert section.id == assigns(:section).id
    assert recipe.id == assigns(:recipe).id
  end

  test "should update a recipe" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    recipe = sections(:appetizers).recipes.first
    xhr :put, :update, section_id: section.id, id: recipe.id, recipe: {
      name: recipe.name,
      ingredient_list: recipe.ingredient_list,
      ingredient_list_2: recipe.ingredient_list_2,
      ingredients_uses_two_columns: recipe.ingredients_uses_two_columns,
      instructions: recipe.instructions,
      submitted_by_title: recipe.submitted_by_title,
      submitted_by: recipe.submitted_by,
      servings: "15 persons",
      force_own_page: recipe.force_own_page,
      shared: recipe.shared
    }
    assert_response :success
  end

  test "should alert the user the recipe is not valid and save valid fields" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    recipe = sections(:appetizers).recipes.first
    xhr :put, :update, section_id: section.id, id: recipe.id, recipe: {
      name: "",
      ingredient_list: recipe.ingredient_list,
      ingredient_list_2: recipe.ingredient_list_2,
      ingredients_uses_two_columns: recipe.ingredients_uses_two_columns,
      instructions: recipe.instructions,
      submitted_by_title: recipe.submitted_by_title,
      submitted_by: recipe.submitted_by,
      servings: "100 persons",
      force_own_page: recipe.force_own_page,
      shared: recipe.shared,
      story: ""
    }
    assert_response :success
    assert assigns(:recipe).errors.any?
    assert_equal "100 persons", assigns(:recipe).servings
  end

  test "should create a new recipe" do
    user = users(:brian_smith)
    login_as_with_cookbook user, cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    assert_difference "section.recipes.count" do
      get :new, section_id: section.id
    end
    assert_response :success
    assert_equal "My new recipe was added to the #{section.name} recipes", flash[:notice]
    assert assigns(:recipe).user.id == user.id
  end

  test "should destroy a recipe" do
    login_as_with_cookbook users(:brian_smith), cookbooks(:brian_smith_first_cookbook)
    section = sections(:appetizers)
    recipe = section.recipes.first
    assert_difference "section.recipes.count", -1 do
      delete :destroy, section_id: section.id, id: recipe.id
    end
    assert_response :redirect
    assert_redirected_to sections_path
  end

  test "should not being able to modify a recipe if contributor but not author" do
    contributor = users(:adam_smith)
    owner = users(:brian_smith)
    cookbook = owner.cookbooks.last
    section = cookbook.sections.first
    recipe = section.recipes.first
    login_as_with_cookbook contributor, cookbook
    get :edit, section_id: section.id, id: recipe.id
    assert_response :redirect
    assert_redirected_to sections_path
    assert_equal "You are not allowed to edit this recipe.", flash[:alert]
  end

  test "should be able to modify an existing recipe if owner but not author" do
    contributor = users(:adam_smith)
    owner = users(:brian_smith)
    cookbook = owner.cookbooks.last
    section = cookbook.sections.first
    recipe = recipes(:recipe_2)
    login_as_with_cookbook owner, cookbook
    get :edit, section_id: section.id, id: recipe.id
    assert_response :success
  end

  test "should render a recipe preview" do
    cookbook = cookbooks(:brian_smith_first_cookbook)
    section = cookbook.sections.first
    recipe = section.recipes.first
    login_as_with_cookbook users(:brian_smith), cookbook
    xhr :get, :preview, section_id: section.id, id: recipe.id
    assert_response :success
  end
end
