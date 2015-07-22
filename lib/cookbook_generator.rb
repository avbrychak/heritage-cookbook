require 'pdf_book'
require 'prawn/measurement_extensions'

# This class generate the cookbook PDF file or part of it. 
# It use the PDFBook class to manage PDF document content.
class CookbookGenerator

  # The PDFBook instance
  attr_reader :document

  HC_PAGE_HEIGHT            = 9.in
  HC_PAGE_WIDTH             = 6.in
  HC_PAGE_MARGIN            = {:top => 0.375.in, :right => 0.625.in, :left => 0.625.in, :bottom => 0.55.in}
  HC_COVER_MARGIN           = {:top => 0, :right => 0, :left => 0, :bottom => 0}
  HC_USER_COVER_MARGIN      = {:top => 13.mm, :right => 13.mm, :left => 13.mm, :bottom => 15.mm} 
  HC_EVEN_MARGIN            = HC_PAGE_MARGIN
  HC_ODD_MARGIN             = HC_PAGE_MARGIN
  HC_LINE_HEIGHT            = 2
  HC_GAP                    = 0.143.in
  USER_CUSTOM_TEMPLATE_1_ID = 7  # Special template 
  USER_CUSTOM_TEMPLATE_2_ID = 8  # Special template 
  FONTS_DIR                 = Rails.root.join("vendor", "assets", "fonts").to_path # On ubuntu: `ttf-mscorefonts-installer` (from 'multiverse' repo)
  TITLE_FONT_SIZE           = 18.pt
  TEXT_FONT_SIZE            = 11.pt

  # Returns the number of pages on the cookbook.
  def self.get_book_length(cookbook)

    # Front cover, inside cover
    page_number = 4

    # Introduction
    page_number += get_introduction_length(cookbook)[:page]

    # Note Page
    page_number+=1 if page_number % 2 == 1

    # ToC 
    page_number += 1

    cookbook.sections.each do |section|
      new_section = Section.find(section.id)
      
      if new_section.has_children?

        # Section pages always start on the right page
        if page_number % 2 == 0
          page_number+=1 
        else
          page_number+=2
        end

        # Have to add all the recipes up for the section and then round up to
        # account for half page recipes and the extra 1/2 page empty at the end
        # if there's an odd number of them
        section_pages = 0
        new_section.recipes.each do |recipe| 
          if (recipe.pages == 0.5 && recipe.force_own_page?)
            section_pages+=1
          else
            section_pages+=recipe.pages
          end
        end
        page_number += section_pages.ceil
      
        section_pages = 0
        new_section.extra_pages.each {|extra_page| section_pages+=extra_page.pages}
        page_number += section_pages.ceil
      end
    end
    
    if cookbook.show_index
      page_number += 1 if page_number % 2 == 0
      page_number += get_index_length(cookbook)
    end
    
    # The back cover page always end on the left page
    if page_number % 2 == 0
      page_number += 3 
    else
      page_number += 2
    end
    
    # The back cover
    page_number += 1
    return page_number.to_i

  end

  # Returns the number of pages on the recipe
  def self.get_recipe_length(recipe)
    book = CookbookGenerator.new
    book.render_recipe recipe

    book.document.render
    page_number = book.document.pages
    last_page_position = book.document.last_position

    return {page: page_number, y: last_page_position}
  end

  # Returns the number of pages on the recipe story
  def self.get_story_length(recipe)    

    book = CookbookGenerator.new

    recipe_page = PDFBook::Section.new
    book.render_recipe_story(recipe_page, recipe)

    book.document << recipe_page
    book.document.render

    page_number = book.document.pages
    last_page_position = book.document.last_position

    return {page: page_number, y: (last_page_position) ? last_page_position : nil}
  end

  # Returns the number of pages on the introduction/dedication
  def self.get_introduction_length(cookbook)
    
    # To prevent mangling of the actual object (???)
    # cookbook = cookbook.clone
    
    book = CookbookGenerator.new cookbook: cookbook
    book.render_introduction

    book.document.render
    page_number = book.document.pages
    last_page_position = book.document.last_position    

    return {page: page_number, y: (last_page_position) ? pt2mm(fpdf_y(last_page_position)) : 0}
  end

  # Returns the number of pages on an extra page section
  def self.get_extra_page_length(extra_page)
    book = CookbookGenerator.new
    book.render_extra_page extra_page

    book.document.render
    page_number = book.document.pages
    last_page_position = book.document.last_position    

    return {page: page_number, y: (last_page_position) ? pt2mm(fpdf_y(last_page_position)) : 0}
  end

  # Returns the number of pages on the index
  def self.get_index_length(cookbook)
    book = CookbookGenerator.new cookbook: cookbook
    book.build_fake_index
    book.render_index

    book.document.render
    return book.document.pages
  end

  # Returns the number of color pages in a cookbook
  def self.get_book_color_pages(cookbook)
    color_pages = 0

    # The inner cover color count depends on the inner cover image settings on template 8.
    # On other templates, the inner cover is color if the cookbook grayscale is set to color.
    if cookbook.template.template_type == USER_CUSTOM_TEMPLATE_2_ID
      color_pages += 1 if cookbook.user_inner_cover_image? && !cookbook.inner_cover_image_grayscale?
    else
      color_pages += 1 unless cookbook.grayscale?
    end

    # The TOC page is color if the cookbook grayscale is set to color, except for template 8 which is B&W text only
    color_pages += 1 if !cookbook.grayscale? && cookbook.template.template_type != USER_CUSTOM_TEMPLATE_2_ID

    # The introduction page is color if the image on it is color on template 8.
    # The introduction page is color if the overall setting is for color, or the image on it is in color
    if cookbook.template.template_type == USER_CUSTOM_TEMPLATE_2_ID
      color_pages += 1 if cookbook.intro_image? && !cookbook.intro_image_grayscale?
    else
      color_pages += 1 if !cookbook.grayscale? || (cookbook.intro_image? && !cookbook.intro_image_grayscale?)
    end

    cookbook.sections.each do |section|
      new_section = Section.find(section.id)
      
      if new_section.has_children?
        # The section page
        color_pages += 1 unless cookbook.grayscale?
      
        # The photos on the recipes
        new_section.recipes.each do |recipe|
          color_pages += 1 if recipe.photo? && !recipe.grayscale?
        end
      
        # The photos on the extra_pages
        new_section.extra_pages.each do |extra_page|
          color_pages += 1 if extra_page.photo? && !extra_page.grayscale?
        end
      end
    end
    return color_pages.to_i
  end

  # Create a new PDF Document.
  # version: :preview or :final.
  # cookbook: main Cookbook to render.
  def initialize(options={})
    @version  = options[:version] ||= :preview
    @cookbook = options[:cookbook]

    # Use high-def images for this cookbook if it's not a preview
    @cookbook.template.image_version = 'original' if ! is_preview?

    # Create a new PDFBook
    @document = PDFBook::Document.new(
      font: 'Baskerville',
      page_size: [HC_PAGE_WIDTH, HC_PAGE_HEIGHT],
      page_margin_left: HC_PAGE_MARGIN[:left],
      page_margin_right: HC_PAGE_MARGIN[:right],
      page_margin_top: HC_PAGE_MARGIN[:top],
      page_margin_bottom: HC_PAGE_MARGIN[:bottom],
      watermark: (is_preview?) ? 'P R E V I E W' : false,
      layout: options[:layout]
    )

    # Import Basketville font family
    # DFont index:
    # * 1: Regular
    # * 2: Italic
    # * 3: Bold Italic
    # * 4: Thin Bold
    # * 5: Bold
    @document.font_families = {
      "Baskerville" => { 
        bold:        {file: "#{FONTS_DIR}/Baskerville.dfont", font: 4},
        italic:      {file: "#{FONTS_DIR}/Baskerville.dfont", font: 2},
        bold_italic: {file: "#{FONTS_DIR}/Baskerville.dfont", font: 3},
        normal:      {file: "#{FONTS_DIR}/Baskerville.dfont", font: 1}
      },
      "Arial" => {  
        bold:        "#{FONTS_DIR}/Arial_Bold.ttf",
        italic:      "#{FONTS_DIR}/Arial_Italic.ttf",
        bold_italic: "#{FONTS_DIR}/Arial_Bold_Italic.ttf",
        normal:      "#{FONTS_DIR}/Arial.ttf"
      },
      "Times" => {
        bold:        "#{FONTS_DIR}/Times_New_Roman_Bold.ttf",
        italic:      "#{FONTS_DIR}/Times_New_Roman_Italic.ttf",
        bold_italic: "#{FONTS_DIR}/Times_New_Roman_Bold_Italic.ttf",
        normal:      "#{FONTS_DIR}/Times_New_Roman.ttf"
      },
      "Freesketch" => {
        bold:        "#{FONTS_DIR}/artill - Sketch Gothic Light.ttf",
        italic:      "#{FONTS_DIR}/artill - Sketch Gothic Light.ttf",
        bold_italic: "#{FONTS_DIR}/artill - Sketch Gothic Light.ttf",
        normal:      "#{FONTS_DIR}/artill - Sketch Gothic Light.ttf"
      },
      "Typesenses" => {
        bold:        "#{FONTS_DIR}/typesenses__wishesscriptcapstextbold.ttf",
        italic:      "#{FONTS_DIR}/typesenses__wishesscriptcapstextbold.ttf",
        bold_italic: "#{FONTS_DIR}/typesenses__wishesscriptcapstextbold.ttf",
        normal:      "#{FONTS_DIR}/typesenses__wishesscriptcapstextbold.ttf"
      },
      "Cacpinaf" => {
        bold:        "#{FONTS_DIR}/CACPINAF.TTF",
        italic:      "#{FONTS_DIR}/CACPINAF.TTF",
        bold_italic: "#{FONTS_DIR}/CACPINAF.TTF",
        normal:      "#{FONTS_DIR}/CACPINAF.TTF"
      },
      "Gotham" => {
        bold:        "#{FONTS_DIR}/Gotham-Bold.ttf",
        italic:      "#{FONTS_DIR}/Gotham-Book.ttf",
        bold_italic: "#{FONTS_DIR}/Gotham-Book.ttf",
        normal:      "#{FONTS_DIR}/Gotham-Book.ttf"
      }
    }
  end

  # Add entire cookbook content to the PDF document.
  def render_cookbook

    # Use high-def template image for this cookbook if it's not a preview
    @cookbook.template.image_version = 'original' if !is_preview?

    render_cover
    render_blank_page
    render_inner_cover
    render_blank_page
    render_introduction
    render_notes_page if @document.pages % 2 == 1
    render_old_table_of_contents
    render_blank_page
    @cookbook.sections.each do |section|
      render_section(section, true) if section.has_children?
    end
    render_index if @cookbook.show_index
    render_blank_page if @document.pages % 2 == 0
    render_blank_page
    render_blank_page
    render_back_cover
  end

  # Adds the cover page of a cookbook to the pdf document.
  def render_cover
    template = @cookbook.template
    cover = nil

    # Build the cover page
    # Template 8 has special margins
    if template.id == USER_CUSTOM_TEMPLATE_2_ID
      cover_image = (@cookbook.user_cover_image?) ? @cookbook.image_path('user_cover_image') : false
      cover = PDFBook::Section.new(
        background: cover_image,
        background_size: :margin,
        page_margin_left: HC_USER_COVER_MARGIN[:left],
        page_margin_right: HC_USER_COVER_MARGIN[:right],
        page_margin_top: HC_USER_COVER_MARGIN[:top],
        page_margin_bottom: HC_USER_COVER_MARGIN[:bottom]
      )
    else
      cover = PDFBook::Section.new(
        background: @cookbook.template.cover_image,
        background_size: :fullpage,
        page_margin_left: HC_COVER_MARGIN[:left],
        page_margin_right: HC_COVER_MARGIN[:right],
        page_margin_top: HC_COVER_MARGIN[:top],
        page_margin_bottom: HC_COVER_MARGIN[:bottom]
      )
    end

    # Display user's cover image if exist
    if @cookbook.template.has_image == 1 && @cookbook.user_image?
      cover.add_image @cookbook.image_path('user_image'), 
        position: @cookbook.template.cover_user_image_y.in,
        max_width: @cookbook.template.cover_user_image_max_width.in,
        max_height: @cookbook.template.cover_user_image_max_height.in
    end

    # Show the book title (taglines)
    taglines = []
    1.upto(@cookbook.template.tag_lines) do |i|
      tagline = eval("@cookbook.tag_line_#{i}[0..@cookbook.template.max_tag_line_#{i}_length]")
      tagline = ' ' if tagline.empty?
      taglines << tagline
    end
    cover.add_text taglines.join("\n"),
      position: @cookbook.template.cover_title_y.in,
      font_style: font_style(@cookbook.template.cover_title_font_style),
      font_size: @cookbook.template.cover_title_font_size.to_i,
      align: :center, 
      line_height: 4,
      color: (@cookbook.template.cover_color) ? @cookbook.template.cover_color : @cookbook.template.book_color,
      font: @cookbook.template.book_font

    @document << cover
  end

  # Adds the inner cover page of a cookbook to the pdf document
  def render_inner_cover
    template = @cookbook.template
    inner_cover = nil

    # Build the inner cover
    # Template 8 has special margins
    if template.id == USER_CUSTOM_TEMPLATE_2_ID
      inner_cover_image = (@cookbook.user_inner_cover_image?) ? @cookbook.image_path('user_inner_cover_image') : false
      inner_cover = PDFBook::Section.new(
        background: inner_cover_image,
        background_size: :margin,
        page_margin_left: HC_USER_COVER_MARGIN[:left],
        page_margin_right: HC_USER_COVER_MARGIN[:right],
        page_margin_top: HC_USER_COVER_MARGIN[:top],
        page_margin_bottom: HC_USER_COVER_MARGIN[:bottom]
      )
    else
      inner_cover = PDFBook::Section.new(
        background: template.inner_cover_image(@cookbook.grayscale==1),
        background_size: :fullpage,
        page_margin_left: HC_COVER_MARGIN[:left],
        page_margin_right: HC_COVER_MARGIN[:right],
        page_margin_top: HC_COVER_MARGIN[:top],
        page_margin_bottom: HC_COVER_MARGIN[:bottom]
      )
    end

    # Show the book title (taglines) 
    if template.show_book_title_on_inner_cover == 1
      taglines = []
      1.upto(template.tag_lines) do |i|
        tagline = eval("@cookbook.tag_line_#{i}[0..template.max_tag_line_#{i}_length]")
        tagline = ' ' if tagline.empty?
        taglines << tagline
      end
      inner_cover.add_text taglines.join("\n"),
        position: template.inner_cover_title_y.in,
        font_style: font_style(template.cover_title_font_style),
        font_size: template.inner_cover_font_size,
        align: :center, 
        line_height: 4,
        color: (@cookbook.grayscale == 1) ? "000000" : template.book_color,
        font: template.book_font
    end

    @document << inner_cover
  end

  # Add the notes page
  def render_notes_page

    # Build the note page
    note_page = PDFBook::Section.new

    # Show the title
    note_page.add_text "Notes",
      position: 7.in + HC_PAGE_MARGIN[:bottom],
      font_size: 17,
      align: :center,
      font_style: :bold,
      line_height: HC_LINE_HEIGHT,
      gap: HC_GAP

    note_page.add_custom move_down: 2.2.mm

    # Show note lines
    7.times do
      note_page.add_custom({
        line_width: 0.2.mm,
        stroke_horizontal_rule: nil,
        move_down: 15.5.mm,
      })
    end

    # Show footer notes
    footer_notes = [
      'Printed in Canada',
      Time.now.year.to_s
    ]
    note_page.add_text 'This book was created & published with the help of',
      position: 1.4.in,
      font_size: 9,
      align: :center,
      gap: 4.mm
    note_page.add_text 'HeritageCookbook.com',
      font_size: 11,
      align: :center, 
      gap: 4.mm,
      font_style: font_style('BI')
    note_page.add_text footer_notes.join("\n"),
      font_size: 9,
      align: :center,
      line_height: 4.mm

    @document << note_page
  end

  # Add Introduction to the PDF document.
  # Support for 3 Layouts: With Text only, With Image only and With Text and Image.
  def render_introduction

    # Introduction is optional, do nothing if the intro_type is equal to 2
    if @cookbook.intro_type != 2
    
      introduction = PDFBook::Section.new

      # Introduction with Text and Image
      if @cookbook.intro_text && @cookbook.intro_image?

        # Show the introduction / dedication title
        introduction.add_text (@cookbook.intro_type==0 ? 'Introduction' : 'Dedication'),
          font_size: TITLE_FONT_SIZE,
          align: :center, 
          gap: HC_GAP

        # Show the user intro image
        introduction.add_image @cookbook.image_path('intro_image'),
          max_height: active_area_size[:height] / 2,
          gap: HC_GAP

        # Show text
        introduction.add_text @cookbook.intro_text,
          align: (@cookbook.center_introduction) ? :center : :left,
          font_size: TEXT_FONT_SIZE,
          line_height: HC_LINE_HEIGHT,
          gap: HC_GAP

      # Introduction with Text only
      elsif @cookbook.intro_text && !@cookbook.intro_image?
        
        # Show the introduction / dedication title
        introduction.add_text (@cookbook.intro_type==0 ? 'Introduction' : 'Dedication'),
          font_size: TITLE_FONT_SIZE,
          align: :center, 
          gap: HC_GAP,
          position: origin(padding_top: 0.75.in)

        # Show text
        introduction.add_text @cookbook.intro_text,
          align: (@cookbook.center_introduction) ? :center : :left,
          font_size: TEXT_FONT_SIZE,
          line_height: HC_LINE_HEIGHT,
          gap: HC_GAP

      # Introduction with Image only
      elsif !@cookbook.intro_text && @cookbook.intro_image?

        # Portrait image
        begin
          dimension = Paperclip::Geometry.from_file @cookbook.image_path('intro_image')
          if image_orientation(dimension.width, dimension.height) == :portrait

            # Show the introduction / dedication title
            introduction.add_text (@cookbook.intro_type==0 ? 'Introduction' : 'Dedication'),
              font_size: TITLE_FONT_SIZE,
              align: :center, 
              gap: HC_GAP,
              position: origin(padding_top: 0.75.in)        

            # Show the user intro image
            introduction.add_image @cookbook.image_path('intro_image')

          # Landscape image
          else
            # Vertically centred
            introduction.vertical_align = :center

            # Show the introduction / dedication title
            introduction.add_text (@cookbook.intro_type==0 ? 'Introduction' : 'Dedication'),
              font_size: TITLE_FONT_SIZE,
              align: :center, 
              gap: HC_GAP

            # Show the user intro image
            introduction.add_image @cookbook.image_path('intro_image'),
              max_height: active_area_size[:height] / 2
          end
        rescue Paperclip::Errors::NotIdentifiedByImageMagickError => e
          if SKIP_IMAGE_NOT_FOUND
            puts "Image missing: #{recipe.pdf_photo(@version)}"
          else
            raise Paperclip::Errors::NotIdentifiedByImageMagickError, "#{e.message} - #{recipe.pdf_photo(@version)}"
          end
        end
      end

      @document << introduction
    end
  end

  # Previews a section with all the recipes
  def render_section(section, show_recipes=true)
    template = @cookbook.template

    # Build the section page
    # Template 8 has different workaround, use the user photo as the background
    section_page = nil
    if template.id == USER_CUSTOM_TEMPLATE_2_ID
      divider_image = (section.photo?) ? section.pdf_image(@version) : template.divider_image(section.cookbook.grayscale==1)
      section_page = PDFBook::Section.new(
        background: divider_image,
        background_size: (section.photo?) ? :margin : :fullpage,
        page_margin_left: HC_USER_COVER_MARGIN[:left],
        page_margin_right: HC_USER_COVER_MARGIN[:right],
        page_margin_top: HC_USER_COVER_MARGIN[:top],
        page_margin_bottom: HC_USER_COVER_MARGIN[:bottom],
        toc: section.name.strip,
        must_be_right: PDFBook::Section.new
      )
    else
      section_page = PDFBook::Section.new(
        background: template.divider_image(section.cookbook.grayscale==1),
        background_size: :fullpage,
        page_margin_left: HC_COVER_MARGIN[:left],
        page_margin_right: HC_COVER_MARGIN[:right],
        page_margin_top: HC_COVER_MARGIN[:top],
        page_margin_bottom: HC_COVER_MARGIN[:bottom],
        toc: section.name.strip,
        must_be_right: PDFBook::Section.new
      )
    end

    # On template 8, display the section name only when no photo has been uploaded
    if !(template.id == USER_CUSTOM_TEMPLATE_2_ID && section.photo?)

      # Show the section name
      header_color = (template.header_color) ? template.header_color : template.book_color
      section_page.add_text section.name,
        position: template.section_header_y.in,
        align: :center,
        color: (section.cookbook.grayscale?) ? "000000" : header_color,
        font_style: font_style(template.headers_font_style),
        font_size: template.headers_font_size,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP,
        font: template.book_font

      # If template support user images for sections
      if template.section_user_image_y
        
        # Show the user image for this section if exist
        if section.photo? 
          section_page.add_image section.pdf_image(@version),
            position: template.section_user_image_y.in,
            max_width: template.section_user_image_max_width.in,
            max_height: template.section_user_image_max_height.in
        end
      end
    end

    @document << section_page

    # Add each recipes
    if show_recipes
      @start_recipe_in_new_page = true
      section.recipes.each do |recipe|
        render_recipe recipe, recipe.force_own_page?
      end
    end
    
    # Add each extra pages
    section.extra_pages.each do |extra_page| 
      render_extra_page extra_page
    end
  end  

  # Add a recipe to the PDF document.
  # Split the recipe on 2 pages if it contain an image.
  def render_recipe(recipe, force_new_page=false)

    # Build the recipe page
    recipe_section = nil
    recipe_photo_section = false
    new_page = false

    if @start_recipe_in_new_page || force_new_page || @document.sections.empty?
      new_page = true
      recipe_section = PDFBook::Section.new(
        page_number: true,
        index: recipe.name.strip
      )
    else
      new_page = false
      recipe_section = @document.sections.last
      recipe_section.add_custom move_cursor_to: active_area_size[:height] / 2
      recipe_section.index = [recipe_section.index, recipe.name.strip]
    end

    # If this is a small recipe, start the next one on the same page
    if recipe.pages == 0.5
      @start_recipe_in_new_page = true if @start_recipe_in_new_page.nil? # The half recipe was started in a new page if undefined
      @start_recipe_in_new_page = !@start_recipe_in_new_page
      @start_recipe_in_new_page = true if recipe.force_own_page? # start the next recipe in a new page if the recipe was asked to be on its own page
    end

    # Show the title
    recipe_section.add_text recipe.name.strip,
      font_size: TITLE_FONT_SIZE,
      gap: HC_GAP / 4

    # Show the 'Submitted by' mention if exist
    if !recipe.submitted_by.empty?
      recipe_section.add_text (recipe.submitted_by_title.empty?) ? "<i>#{recipe.submitted_by_title}</i> #{recipe.submitted_by}" : "<i>#{recipe.submitted_by_title}</i> #{recipe.submitted_by}",
        font_size: TEXT_FONT_SIZE,
        gap: HC_GAP / 4
    end

    # Draw an horizontal line
    recipe_section.add_custom(
      line_width: 0.5,
      horizontal_rule: nil,
      move_down: 0.2.in
    )

    # Show recipe in two page format if an image exist or in one page format if not
    # Place everything on one page if asked by the user
    if !recipe.photo? || recipe.single_page

      # Add the sorty under the recipe
      render_recipe_story(recipe_section, recipe)

    else

      # Build the recipe photo page
      recipe_photo_section = PDFBook::Section.new(
        page_number: true,
        vertical_align: :center
      )

      # Add the photo and the sorty to the new page
      render_recipe_story(recipe_photo_section, recipe)
    end

    # Show ingredient list
    if recipe.ingredients_uses_two_columns?
      column_options = {
        font_size: TEXT_FONT_SIZE,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP
      }
      recipe_section.add_column_text column_options, 
        recipe.ingredient_list, 
        recipe.ingredient_list_2
    else
      recipe_section.add_text recipe.ingredient_list,
        font_size: TEXT_FONT_SIZE,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP
    end

    # Show recipe instructions
    if recipe.instructions
      recipe_section.add_text recipe.instructions,
        font_size: TEXT_FONT_SIZE,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP
    end

    # Show recipe servings if exist
    if recipe.servings && !recipe.servings.empty?
      recipe_section.add_text "<i>Yield</i>: #{recipe.servings}",
        font_size: TEXT_FONT_SIZE,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP
    end

    @document << recipe_photo_section if recipe_photo_section
    @document << recipe_section if new_page
  end

  # Display the recipe story on a recipe section
  def render_recipe_story(recipe_section, recipe)

    # Display the photo if exist
    if recipe.photo?
      
      # Show the photo, max height = 1/2 page if image in landscape, if recipe have a story, or if recipe must be single page only
      begin
        dimension  = Paperclip::Geometry.from_file recipe.pdf_photo(@version)
        max_height = (image_orientation(dimension.width, dimension.height) == :landscape || !recipe.story.empty? || recipe.single_page ) ? active_area_size[:height] / 2 : false
        recipe_section.add_image recipe.pdf_photo(@version),
          max_height: max_height,
          gap: (!recipe.story.empty? || recipe.single_page) ? HC_GAP : false
      rescue Paperclip::Errors::NotIdentifiedByImageMagickError => e
        if SKIP_IMAGE_NOT_FOUND
          puts "Image missing: #{recipe.pdf_photo(@version)}"
        else
          raise Paperclip::Errors::NotIdentifiedByImageMagickError, "#{e.message} - #{recipe.pdf_photo(@version)}"
        end
      end
    end

    # Add the recipe story
    if recipe.story && !recipe.story.empty?
      recipe_section.add_text recipe.story,
        font_size: TEXT_FONT_SIZE,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP
    end
  end

  # Add an extra_page to the PDF document.
  def render_extra_page(extra_page)

    # Create the extra page
    extra_page_section = PDFBook::Section.new( 
      page_number: true, 
      extra: (extra_page.index_as_recipe?) ? false : extra_page.name.strip,
      index: (extra_page.index_as_recipe?) ? extra_page.name.strip : false
    )

    # Show the title
    extra_page_section.add_text extra_page.name.strip,
      font_size: TITLE_FONT_SIZE,
      gap: HC_GAP / 4

    # Draw an horizontal line
    extra_page_section.add_custom(
      line_width: 0.5,
      horizontal_rule: nil,
      move_down: 0.3.in
    )

    # Show the extra page image if exist.
    # If no text, allow the image to be full page.
    if extra_page.photo?
      extra_page_section.add_image extra_page.pdf_photo(@version),
        max_height: (extra_page.text && !extra_page.text.empty?) ? active_area_size[:height] / 2 : false,
        gap: HC_GAP
    end

    # Show the extra page text
    extra_page_section.add_text extra_page.text,
      font_size: TEXT_FONT_SIZE,
      line_height: HC_LINE_HEIGHT,
      gap: HC_GAP

    @document << extra_page_section
  end

  # Adds the back cover to the PDF
  def render_back_cover
    template = @cookbook.template

    # Build the back cover page
    back_cover = PDFBook::Section.new(
      page_margin_left: HC_PAGE_MARGIN[:left],
      page_margin_right: HC_PAGE_MARGIN[:right],
      page_margin_top: HC_PAGE_MARGIN[:top],
      page_margin_bottom: HC_PAGE_MARGIN[:bottom]
    )
    
    # Add the cover image
    back_cover.add_image @cookbook.template.back_cover_image, 
      max_height: 19.mm,
      position: 22.mm

    @document << back_cover
  end

  # Add a table of content to the PDF document.
  # (New Layout).
  def render_table_of_contents

    # Build the Table of Content page
    toc_template = PDFBook::Section.new

    # Show the title
    toc_template.add_text "Table of Contents",
      align: :center,
      font_size: TITLE_FONT_SIZE,
      gap: 0.43.in,
      position: origin(padding_top: 0.75.in)

    # Configure the table of content
    @document.table_of_content_options(
      template: toc_template,
      start_at: 2,
      position: 6.47.in
    )

    @document << :table_of_content
  end

  # Add a table of content to the PDF document.
  # (Old Layout).
  def render_old_table_of_contents
    template = @cookbook.template

    # Build the Table of Content page
    toc_template = PDFBook::Section.new(
      background: template.toc_image(@cookbook.grayscale==1),
      background_size: :fullpage,
      page_margin_left: HC_COVER_MARGIN[:left],
      page_margin_right: HC_COVER_MARGIN[:right],
      page_margin_top: HC_COVER_MARGIN[:top],
      page_margin_bottom: HC_COVER_MARGIN[:bottom]
    )

    # Show the title
    toc_template.add_text "Table of Contents",
      position: template.toc_header_y.in,
      align: :center, 
      font_size: TITLE_FONT_SIZE,
      gap: 0.43.in

    # Configure the table of content
    introduction_pages_number = CookbookGenerator.get_introduction_length(@cookbook)[:page]
    introduction_pages_number += 1 if introduction_pages_number % 2 != 0 # "note page" inclusion
    @document.table_of_content_options(
      template: toc_template,
      width: 2.65.in,
      position: template.toc_header_y.in - TITLE_FONT_SIZE - 0.2.in,
      start_at: 6+introduction_pages_number, # start counting at the third page, start printing on the first recipe
      layout: :old
    )

    @document << :table_of_content
  end

  # Add an index to the PDF document.
  def render_index
    
    # Build the Index template page
    index_template = PDFBook::Section.new( 
      page_number: true
    )

    # Add the title
    index_template.add_text "Index",
      font_size: TITLE_FONT_SIZE,
      gap: HC_GAP / 4

    # Draw an horizontal line
    index_template.add_custom(
      line_width: 0.5,
      horizontal_rule: nil,
      move_down: 0.3.in
    )

    # Configure the document index system
    @document.index_options(
      template: index_template,
      position: 7.333.in
    )

    @document << :index
  end

  # Add a blank page to the PDF document.
  def render_blank_page
    blank_page = PDFBook::Section.new
    @document << blank_page
  end

  # Build index entries for a cookbook without adding pages.
  # This is used for index preview and index lenght calculator.
  def build_fake_index

    # PDF book toc, index and extras will be entered manually to add entries to the index
    @document.toc = {}
    @document.index = {}
    @document.extras = {}

    sections = @cookbook.sections
    page = 8

    # Need to show duplicate names in extra pages and recipes
    # If two extra pages (or recipes) have the same name, they must appear two times in the index file.
    # => Using unique label name: recipe_name{{page_number}}
    sections.each do |section|
      if section.has_children?

        @document.toc[section.name] = page = page+1

        section.recipes.each do |recipe|
          page_num = page = page+recipe.pages.round
          @document.index["#{recipe.name}{{#{page_num}}}"] = page_num
        end

        section.extra_pages.each do |extra_page|
          page_num = page = page+extra_page.pages.round
          if extra_page.index_as_recipe?
            @document.index["#{extra_page.name}{{#{page_num}}}"] = page_num
          else  
            @document.extras["#{extra_page.name}{{#{page_num}}}"] = page_num
          end
        end
      end
    end
  end

  private

  # Return true if the book is in preview mode
  def is_preview?
    return (@version == :preview)
  end

  # Return the with and height of the bounding box
  def active_area_size
    width  = HC_PAGE_WIDTH - HC_PAGE_MARGIN[:left] - HC_PAGE_MARGIN[:right]
    height = HC_PAGE_HEIGHT - HC_PAGE_MARGIN[:top] - HC_PAGE_MARGIN[:bottom]
    return {width: width, height: height}
  end

  # Return the Y coordinate position modified by the given padding.
  def origin(padding)
    padding[:padding_top] ||= 0

    origin = active_area_size[:height]
    origin -= padding[:padding_top]
  end

  # Return the image orientation for an image width and height
  def image_orientation(width, height)
    (width > height) ? :landscape : :portrait
  end

  # FPDF (library used by the old script) use the left-top corner of the page as origin.
  # Prawn use the left-bottom corner of the bounding box as origin.
  # This method return the Prawn coordinate corresponding to an FPDF coordinate,
  # or the return FPDF coordinate corresponding to a Prawn coordinate.
  def fpdf_y(y, cover=false)
    if @cookbook.template.template_type < 9
      if cover
        return HC_PAGE_HEIGHT - HC_COVER_MARGIN[:bottom] - y
      else
        return HC_PAGE_HEIGHT - HC_PAGE_MARGIN[:bottom] - y
      end
    else
      return y
    end
  end

  def self.fpdf_y(y, cover=false)
    if cover
      return HC_PAGE_HEIGHT - HC_COVER_MARGIN[:bottom] - y
    else
      return HC_PAGE_HEIGHT - HC_PAGE_MARGIN[:bottom] - y
    end
  end

  # 1 pt (Prawn mesurement) = 2.834645669291339 mm
  def pt2mm(pt)
    mm=2.834645669291339
    return pt / mm
  end
  def self.pt2mm(pt)
    mm=2.834645669291339
    return pt / mm
  end

  # Fonts style translation beetween FPDF and Prawn.
  def fpdf_font_style(font_style)
    case font_style
    when "I"
      return :italic
    when "IB"
      return :bold_italic
    when "BI"
      return :bold_italic
    when "BIU"
      return :bold_italic
    when ""
      return :normal
    else
      raise "Unknow font style format"
    end
  end

  # Fonts style translation
  # B: bold
  # I: italic
  # BI/IB: bold-italic
  def font_style(font_style)
    case font_style
    when "I"
      return :italic
    when "IB"
      return :bold_italic
    when "BI"
      return :bold_italic
    when "BIU"
      return :bold_italic
    when "B"
      return :bold
    when ""
      return :normal
    else
      raise "Unknow font style format"
    end
  end

  # Conert an integer to a base 16 hexa number.
  def int2hex(int)
    if int < 16
      return "0#{int.to_s(16)}"
    else
      return int.to_s(16)
    end
  end

  # Convert rvb color to hex color.
  def fpdf_color(color)
    rgb = color.split(',')
    return "#{int2hex(rgb[0].to_i)}#{int2hex(rgb[1].to_i)}#{int2hex(rgb[2].to_i)}"
  end
end