# Manage Preview rendering asynchronously.
class CookbookPreviewWorker

  # Build a new cookbook preview.
  def initialize(options)
    @cookbook_id = options[:cookbook].id
    @filename = options[:filename]
  end

  # Preview a section.
  def section(section_id)
    cookbook = Cookbook.find(@cookbook_id)
    section = cookbook.sections.find(section_id)
    @book = CookbookGenerator.new(version: :preview, cookbook: cookbook, layout: :book)
    @book.render_section section
    rendering_filename = "#{@filename}-rendering"
    @book.document.to_file rendering_filename
    File.rename rendering_filename, @filename
  end

  # Preview a recipe.
  def recipe(recipe_id)
    cookbook = Cookbook.find(@cookbook_id)
    recipe = cookbook.recipes.find(recipe_id)
    @book = CookbookGenerator.new(version: :preview, cookbook: cookbook)
    @book.render_recipe recipe
    rendering_filename = "#{@filename}-rendering"
    @book.document.to_file rendering_filename
    File.rename rendering_filename, @filename
  end

  # Preview an extra page.
  def extra_page(extra_page_id)
    cookbook = Cookbook.find(@cookbook_id)
    extra_page = cookbook.extra_pages.find(extra_page_id)
    @book = CookbookGenerator.new(version: :preview, cookbook: cookbook)
    @book.render_extra_page extra_page
    rendering_filename = "#{@filename}-rendering"
    @book.document.to_file rendering_filename
    File.rename rendering_filename, @filename
  end

  # Preview a cookbook.
  def cookbook
    rendering_filename = "#{@filename}-rendering"
    cookbook = Cookbook.find(@cookbook_id)
    cookbook.render_preview rendering_filename
    File.rename rendering_filename, @filename
  end

  # Preview a cookbook cover
  def cover
    cookbook = Cookbook.find(@cookbook_id)
    @book = CookbookGenerator.new(version: :preview, cookbook: cookbook, layout: :book)
    @book.render_cover
    rendering_filename = "#{@filename}-rendering"
    @book.document.to_file rendering_filename
    File.rename rendering_filename, @filename
  end

  # Preview the inner cover and the table of content
  def title_and_toc
    cookbook = Cookbook.find(@cookbook_id)
    @book = CookbookGenerator.new(version: :preview, cookbook: cookbook)
    @book.render_inner_cover
    @book.build_fake_index
    @book.render_old_table_of_contents
    rendering_filename = "#{@filename}-rendering"
    @book.document.to_file rendering_filename
    File.rename rendering_filename, @filename
  end

  # Preview the index page
  def index
    cookbook = Cookbook.find(@cookbook_id)
    @book = CookbookGenerator.new(version: :preview, cookbook: cookbook)
    @book.build_fake_index
    @book.render_index
    rendering_filename = "#{@filename}-rendering"
    @book.document.to_file rendering_filename
    File.rename rendering_filename, @filename
  end

  def introduction
    cookbook = Cookbook.find(@cookbook_id)
    @book = CookbookGenerator.new(version: :preview, cookbook: cookbook)
    @book.render_introduction
    rendering_filename = "#{@filename}-rendering"
    @book.document.to_file rendering_filename
    File.rename rendering_filename, @filename
  end

end