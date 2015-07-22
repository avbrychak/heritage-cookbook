require 'test_helper'
require 'prawn/measurement_extensions'

class CookbookGeneratorTest < ActiveSupport::TestCase

  def setup
    @pdf = CookbookGenerator.new(version: :preview)
    @half_page_y_positon = (CookbookGenerator::HC_PAGE_HEIGHT - CookbookGenerator::HC_PAGE_MARGIN[:top] - CookbookGenerator::HC_PAGE_MARGIN[:bottom]) / 2
  end

  test "should support vertical alignment for page content " do
    book = CookbookGenerator.new(version: :preview)

    # Build an introduction page (Title, Text and Image)
    introduction = PDFBook::Section.new vertical_align: :center

    # Add Title
    introduction.add_text "Introduction", font_size: 20.pt, align: :center, gap: 0.215.in

    # Add add_text
    introduction.add_text lorem, font_size: 11.pt, gap: 0.215.in, line_height: 2

    # Add Picture
    introduction.add_image Rails.root.join("test", "fixtures", "images", "family-landscape.jpg")

    book.document << introduction
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "should keep user entered extra space when displaying text blocks" do
    book    = CookbookGenerator.new version: :preview
    section = PDFBook::Section.new

    # Add add_text
    breaker = "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n                               "
    section.add_text "      #{lorem}#{breaker}#{lorem}", 
      font_size: 11.pt, 
      gap: 0.215.in, 
      line_height: 2

    book.document << section
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "should keep user entered extra space when displaying column text" do
    book    = CookbookGenerator.new version: :preview
    section = PDFBook::Section.new

    # Add add_text
    options = {
      font_size: 11.pt, 
      gap: 0.215.in, 
      line_height: 2
    }
    section.add_column_text options, "oil\n  two cups", "salt"

    book.document << section
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "should have some padding on ingredients columns" do
    book    = CookbookGenerator.new version: :preview
    section = PDFBook::Section.new

    # Add add_text
    options = {
      font_size: 11.pt, 
      gap: 0.215.in, 
      line_height: 2
    }
    section.add_column_text options, "verylooooonnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnggggggggg", "ingredient"

    book.document << section
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for blank page (no page numbers)" do
    book = CookbookGenerator.new version: :preview
    book.render_blank_page
    book.render_blank_page
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for introduction with text and image" do
    cookbook = cookbooks(:introduction_with_text)
    cookbook.intro_image = fixture_image('family-landscape.jpg')
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.render_introduction
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for introduction with text and image > 1 page" do
    cookbook = cookbooks(:introduction_with_text)
    cookbook.intro_text += cookbook.intro_text * 2
    cookbook.intro_image = fixture_image('family-landscape.jpg')
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.render_introduction
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for introduction with text only" do
    cookbook = cookbooks(:introduction_with_text)
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.render_introduction
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for introduction with image only (landscape)" do
    cookbook = cookbooks(:introduction_without_text)
    cookbook.intro_image = fixture_image('family-landscape.jpg')
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.render_introduction
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for introduction with image only (portrait)" do
    cookbook = cookbooks(:introduction_without_text)
    cookbook.intro_image = fixture_image('family-portrait.jpg')
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.render_introduction
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for one page recipe (single column) with 'submitted by'" do
    recipe = recipes(:one_page_recipe_single_column_submission)
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for one page recipe (single column) with no 'submitted by'" do
    recipe = recipes(:one_page_recipe_single_column)
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for one page recipe (double column)" do
    recipe = recipes(:one_page_recipe_double_column)
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for one page recipe (double column) with story" do
    recipe = recipes(:one_page_recipe_double_column_with_story)
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for two pages recipe with image (portrait) and no story" do
    recipe = recipes(:one_page_recipe_double_column)
    recipe.photo = fixture_image('family-portrait.jpg')
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for two pages recipe with image (landscape) and no story" do
    recipe = recipes(:one_page_recipe_double_column)
    recipe.photo = fixture_image('family-landscape.jpg')
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for two pages recipe with image (landscape) and story" do
    recipe = recipes(:one_page_recipe_double_column_with_story)
    recipe.photo = fixture_image('family-landscape.jpg')
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for two pages recipe with image (portrait) and story" do
    recipe = recipes(:one_page_recipe_double_column_with_story)
    recipe.photo = fixture_image('family-portrait.jpg')
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for extra page" do
    extra_page = extra_pages(:simple_recipe_extra_page)
    extra_page.photo = fixture_image('family-landscape.jpg')
    book = CookbookGenerator.new version: :preview
    book.render_extra_page extra_page
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for extra page with no photo" do
    extra_page = extra_pages(:simple_recipe_extra_page)
    book = CookbookGenerator.new version: :preview
    book.render_extra_page extra_page
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for section" do
    section = sections(:meals)
    cookbook = cookbooks(:one_single_page_recipe_single_column)
    book = CookbookGenerator.new version: :preview, cookbook: cookbook
    book.render_section section
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for table of contents" do
    cookbook = cookbooks(:introduction_with_text)
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.document.toc = {
      "Breakfast biscuit and scones" => 7,
      "Muffins" => 21,
      "Quick breads" => 33,
      "Coffee cakes" => 45,
      "Brunch bakes" => 57,
      "Bars and cookies" => 69,
      "Cackes" => 81,
      "Desserts" => 103,
      "Breads" => 123,
      "Gluten free and vegan" => 137
    }

    book.render_table_of_contents
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "old layout for table of contents" do
    cookbook = cookbooks(:introduction_with_text)
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.document.toc = {
      "Breakfast biscuit and scones" => 7,
      "Muffins" => 21,
      "Quick breads" => 33,
      "Coffee cakes" => 45,
      "Brunch bakes" => 57,
      "Bars and cookies" => 69,
      "Cackes" => 81,
      "Desserts" => 103,
      "Breads" => 123,
      "Gluten free and vegan" => 137
    }

    book.render_old_table_of_contents
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "layout for index" do
    cookbook = cookbooks(:introduction_with_text)
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )
    book.document.toc = {
      "Breakfast biscuit and scones" => 7,
      "Muffins" => 21,
      "Quick breads" => 33,
      "Coffee cakes" => 45,
      "Brunch bakes" => 57,
      "Bars and cookies" => 69,
      "Cackes" => 81,
      "Desserts" => 103,
      "Breads" => 123,
      "Gluten free and vegan" => 137
    }
    book.document.index = {
      "Recipe 1" => 9, 
      "Recipe 2" => 10, 
      "Recipe 3" => 12, 
      "Recipe 4" => 15, 
      "Recipe 5" => 35, 
      "Recipe 6" => 37, 
      "Recipe 7" => 46, 
      "Recipe 8" => 48, 
      "Recipe 9" => 49, 
      "Recipe 10" => 58, 
      "Recipe 11" => 61, 
      "Recipe 12" => 70, 
      "Recipe 13" => 72, 
      "Recipe 14" => 77, 
      "Recipe 15" => 82, 
      "Recipe 16" => 84, 
      "Recipe 17" => 86, 
      "Recipe 18" => 88, 
      "Recipe 19" => 90, 
      "Recipe 20" => 99, 
      "Recipe 21" => 107, 
      "Recipe 22" => 110, 
      "Recipe 23" => 115, 
      "Recipe 24" => 127, 
      "Recipe 25" => 130, 
      "Recipe 26" => 138, 
      "Recipe 27" => 167
    }
    book.document.extras = {
      "Extra page 1" => 14,
      "Extra page 2" => 16,
      "Extra page 3" => 135
    }

    book.render_index
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "should render a cookbook" do
    cookbook = cookbooks(:oleg_cookbook)
    book = CookbookGenerator.new(
      cookbook: cookbook,
      version: :preview
    )

    book.render_cookbook
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "two small recipes must be on the same page" do
    recipe1 = recipes(:half_page)
    recipe2 = recipes(:half_page)
    @pdf.render_recipe recipe1, true
    @pdf.render_recipe recipe2
    @pdf.document.render
    assert_equal 1, @pdf.document.pdf.page_count
    @pdf.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "two recipes on the same page must have their index entries" do
    recipe1 = recipes(:oleg_recipe)
    recipe2 = recipes(:half_page)
    @pdf.render_recipe recipe1, true
    @pdf.render_recipe recipe2
    @pdf.document.render
    assert !@pdf.document.index.empty?

    assert_equal 1, @pdf.document.index["Potatoes"]
    assert_equal 1, @pdf.document.index["Half page"]
  end

  test "recipes lenght" do
    recipe = recipes(:half_page)
    recipe_lenght = CookbookGenerator.get_recipe_length(recipe)
    assert_equal 1, recipe_lenght[:page]
    assert (recipe_lenght[:y] > @half_page_y_positon)

    recipe = recipes(:one_page)
    recipe_lenght = CookbookGenerator.get_recipe_length(recipe)
    assert_equal 1, recipe_lenght[:page]
    assert (recipe_lenght[:y] < @half_page_y_positon)

    recipe = recipes(:two_pages)
    recipe_lenght = CookbookGenerator.get_recipe_length(recipe)
    assert_equal 2, recipe_lenght[:page]
  end

  test "book lenght" do
    cookbook = cookbooks(:oleg_cookbook)
    cookbook_lenght = CookbookGenerator.get_book_length(cookbook)
    assert (cookbook_lenght > 1)
  end

  test "story lenght" do
    recipe = recipes(:one_page_recipe_double_column_with_story)
    story_lenght = CookbookGenerator.get_story_length(recipe)
    assert_equal 1, story_lenght[:page]
    assert (story_lenght[:y] > @half_page_y_positon)
  end

  # Extra line between "Pour warm water[...]" and "Add lukewarm milk[...]"
  test "do not add a newline when string take all the width of the cookbook" do
    recipe = recipes(:newline_problem_recipe)
    book = CookbookGenerator.new version: :preview
    book.render_recipe recipe
    book.document.to_file "/tmp/#{__method__}.pdf"
  end

  test "a cookbook index should index all recipes and extra pages with the same names" do
    cookbook = cookbooks(:will_smith_first_cookbook)
    section_1 = cookbook.sections.create(name: "Section 1", position: 0)
    section_2 = cookbook.sections.create(name: "Section 2", position: 1)
    section_1.recipes.create(
      name: "My new recipe", 
      ingredient_list: "",
      instructions: "",
      story: "",
      user: users(:will_smith)
    )
    section_1.recipes.create(
      name: "My new recipe", 
      ingredient_list: "",
      instructions: "",
      story: "",
      user: users(:will_smith)
    )
    section_2.recipes.create(
      name: "My new recipe", 
      ingredient_list: "",
      instructions: "",
      story: "",
      user: users(:will_smith)
    )
    section_1.extra_pages.create(name: "My extra page", user: users(:will_smith), text: "")
    section_1.extra_pages.create(name: "My extra page", user: users(:will_smith), text: "")
    section_2.extra_pages.create(name: "My extra page", user: users(:will_smith), text: "")
    book = CookbookGenerator.new(version: :preview, cookbook: cookbook)
    book.build_fake_index
    book.render_index
    book.document.to_file "/tmp/#{__method__}.pdf"
    assert true
  end
end