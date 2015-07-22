require 'pdf_book'
require 'prawn/measurement_extensions'

class PdfCookbook

  attr_reader :document

  HC_PAGE_HEIGHT            = 228.6.mm 
  HC_PAGE_WIDTH             = 152.4.mm  
  HC_PAGE_MARGIN            = {:top => 15.mm, :right => 19.05.mm, :left => 19.05.mm, :bottom => 15.mm}
  HC_COVER_MARGIN           = {:top => 13.mm, :right => 13.mm, :left => 13.mm, :bottom => 15.mm} 
  HC_ODD_MARGIN             = HC_PAGE_MARGIN  # Right page
  HC_EVEN_MARGIN            = HC_PAGE_MARGIN  # Left page
  HC_LINE_HEIGHT            = 2
  HC_GAP                    = 5.mm
  USER_CUSTOM_TEMPLATE_1_ID = 7  # Special template 
  USER_CUSTOM_TEMPLATE_2_ID = 8  # Special template 
  FONT_DIR                  = "/usr/share/fonts/truetype/msttcorefonts" # On ubuntu: `ttf-mscorefonts-installer` (from 'multiverse' repo)
  # FONT_DIR                  = "/usr/share/fonts/truetype/liberation" # On ubuntu / debian: `apt-get install ttf-liberation`


  # Returns the number of pages on the cookbook
  def self.get_book_length(cookbook)
    # book = PdfCookbook.new
    # book.add_cookbook(cookbook)
    # book.document.pages

    # Front cover, inside cover
    page_number = 4

    # Introduction
    page_number += get_introduction_length(cookbook)[:page]

    # Note, ToC 
    page_number += 3

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
        new_section.recipes.each {|recipe| section_pages+=recipe.pages}
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
    book = PdfCookbook.new
    book.add_recipe(recipe, false, true)
    book.document.render
    page_number = book.document.pages
    last_page_position = book.document.last_position

    # return {page: page_number, y: pt2mm(fpdf_y(last_page_position))}
    return {page: page_number, y: last_page_position}
  end

  # Returns the number of pages on the recipe story
  def self.get_story_length(recipe)    
    book = PdfCookbook.new

    recipe_page = PDFBook::Section.new
    book.add_recipe_story(recipe_page, recipe)

    book.document << recipe_page
    book.document.render

    page_number = book.document.pages
    last_page_position = book.document.last_position

    return {page: page_number, y: (last_page_position) ? last_page_position : nil}
  end

  # Returns the number of pages on the introduction/dedication
  def self.get_introduction_length(cookbook)
    
    # To prevent mangling of the actual object (???)
    cookbook = cookbook.clone
    
    book = PdfCookbook.new
    book.add_introduction(cookbook)

    book.document.render
    page_number = book.document.pages
    last_page_position = book.document.last_position    

    return {page: page_number, y: pt2mm(fpdf_y(last_page_position))}
  end

  # Returns the number of pages on an extra page section
  def self.get_extra_page_length(extra_page)
    book = PdfCookbook.new
    book.add_extra_page(extra_page)

    book.document.render
    page_number = book.document.pages
    last_page_position = book.document.last_position    

    return {page: page_number, y: pt2mm(fpdf_y(last_page_position))}
  end

  # Returns the number of pages on the index
  def self.get_index_length(cookbook)
    book = PdfCookbook.new

    book.build_fake_index(cookbook)

    book.add_index(cookbook)
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

  def initialize(final_mode=false)

    # Is it a preview?
    @final_mode = final_mode

    # Create an empty PDF document
    @document = PDFBook::Document.new(
      font: 'Times',
      page_size: [HC_PAGE_WIDTH, HC_PAGE_HEIGHT],
      page_margin_left: HC_PAGE_MARGIN[:left],
      page_margin_right: HC_PAGE_MARGIN[:right],
      page_margin_top: HC_PAGE_MARGIN[:top],
      page_margin_bottom: HC_PAGE_MARGIN[:bottom],
      watermark: (is_preview?) ? 'P R E V I E W' : false
    )

    # Add Arial and Times fonts
    # @document.font_families = {
    #   "Arial" => {  
    #     bold:        "#{FONT_DIR}/LiberationSans-Bold.ttf",
    #     italic:      "#{FONT_DIR}/LiberationSans-Italic.ttf",
    #     bold_italic: "#{FONT_DIR}/LiberationSans-BoldItalic.ttf",
    #     normal:      "#{FONT_DIR}/LiberationSans-Regular.ttf"
    #   },
    #   "Times" => {
    #     bold:        "#{FONT_DIR}/LiberationSerif-Bold.ttf",
    #     italic:      "#{FONT_DIR}/LiberationSerif-Italic.ttf",
    #     bold_italic: "#{FONT_DIR}/LiberationSerif-BoldItalic.ttf",
    #     normal:      "#{FONT_DIR}/LiberationSerif-Regular.ttf"
    #   }
    # }
    @document.font_families = {
      "Arial" => {  
        bold:        "#{FONT_DIR}/Arial_Bold.ttf",
        italic:      "#{FONT_DIR}/Arial_Italic.ttf",
        bold_italic: "#{FONT_DIR}/Arial_Bold_Italic.ttf",
        normal:      "#{FONT_DIR}/Arial.ttf"
      },
      "Times" => {
        bold:        "#{FONT_DIR}/Times_New_Roman_Bold.ttf",
        italic:      "#{FONT_DIR}/Times_New_Roman_Italic.ttf",
        bold_italic: "#{FONT_DIR}/Times_New_Roman_Bold_Italic.ttf",
        normal:      "#{FONT_DIR}/Times_New_Roman.ttf"
      }
    }
  end

  # Previews the entire cookbook
  def add_cookbook(cookbook)

    # Use high-def template image for this cookbook if it's not a preview
    cookbook.template.image_version = 'original' if ! is_preview?

    add_cover(cookbook)
    add_blank_page
    add_inner_cover(cookbook)
    add_blank_page
    add_introduction(cookbook)
    add_notes_page(cookbook)
    add_table_of_contents(cookbook)
    add_blank_page(true)
    cookbook.sections.each do |section|
      new_section = Section.find(section.id) 
      add_section(new_section, cookbook, true, true) if new_section.has_children?
    end
    add_index(cookbook) if cookbook.show_index
    add_blank_page if @document.pages % 2 == 0
    add_blank_page
    add_blank_page
    add_back_cover(cookbook)
  end

  # Adds the cover page of a cookbook to the pdf document.
  def add_cover(cookbook)
    template = cookbook.template
    cover_image = template.cover_image || cookbook.image_path('user_cover_image')

    # Build the cover page
    cover = PDFBook::Section.new(
      background: cover_image,
      background_size: :margin,
      page_margin_left: HC_COVER_MARGIN[:left],
      page_margin_right: HC_COVER_MARGIN[:right],
      page_margin_top: HC_COVER_MARGIN[:top],
      page_margin_bottom: HC_COVER_MARGIN[:bottom]+2.mm # Need to add ~2 mm to keep the same result as the old lib
    )

    # Display user's cover image if exist
    if template.has_image == 1 && cookbook.image_path('user_image')
      cover.add_image cookbook.image_path('user_image'), 
        position: PdfCookbook.fpdf_y(template.cover_user_image_y.mm+2.mm, true),
        max_width: template.cover_user_image_max_width.mm,
        max_height: template.cover_user_image_max_height.mm,
        mark_image_area: is_preview?
    end

    # Show the book title (taglines) 
    taglines = []
    1.upto(template.tag_lines) do |i|
      tagline = eval("cookbook.tag_line_#{i}[0..template.max_tag_line_#{i}_length]")
      tagline = ' ' if tagline.empty?
      taglines << tagline
    end
    cover.add_text taglines.join("\n"),
      position: PdfCookbook.fpdf_y(template.cover_title_y.mm+2.mm, true),
      font_style: PdfCookbook.fpdf_font_style(template.cover_title_font_style),
      font_size: template.cover_title_font_size.to_i,
      align: :center, 
      line_height: (template.id != USER_CUSTOM_TEMPLATE_1_ID) ? 6 : 2.mm,
      color: PdfCookbook.fpdf_color(template.book_color),
      font: template.book_font

    @document << cover
  end

  # Adds a blank page
  def add_blank_page(page_numbers=false)
    blank_page = PDFBook::Section.new page_number: page_numbers
    @document << blank_page
  end

  # Adds the inner cover page of a cookbook to the pdf document
  def add_inner_cover(cookbook)
    template = cookbook.template
    inner_cover_image = template.inner_cover_image(cookbook.grayscale==1) || cookbook.image_path('user_inner_cover_image')

    # Build the inner cover
    inner_cover = PDFBook::Section.new(
      background: inner_cover_image,
      background_size: :margin,
      page_margin_left: HC_COVER_MARGIN[:left],
      page_margin_right: HC_COVER_MARGIN[:right],
      page_margin_top: HC_COVER_MARGIN[:top],
      page_margin_bottom: HC_COVER_MARGIN[:bottom]+2.mm # Need to add ~2 mm to keep the same result as the old lib
    )

    # Show the book title (taglines) 
    if template.show_book_title_on_inner_cover == 1
      taglines = []
      1.upto(template.tag_lines) do |i|
        tagline = eval("cookbook.tag_line_#{i}[0..template.max_tag_line_#{i}_length]")
        tagline = ' ' if tagline.empty?
        taglines << tagline
      end
      inner_cover.add_text taglines.join("\n"),
        position: PdfCookbook.fpdf_y(template.cover_title_y.mm+2.mm, true),
        font_style: PdfCookbook.fpdf_font_style(template.cover_title_font_style),
        font_size: template.cover_title_font_size,
        align: :center, 
        line_height: (template.id == USER_CUSTOM_TEMPLATE_1_ID) ? 6 : 2.mm,
        color: (cookbook.grayscale == 1) ? "000000" : PdfCookbook.fpdf_color(template.book_color),
        font: template.book_font
    end

    @document << inner_cover
  end

  # Adds the introduction/dedication to the pdf cookbook
  def add_introduction(cookbook, page_number=true)
    template = cookbook.template

    # Build the introduction page
    introduction = PDFBook::Section.new page_number: true

    # Show the introduction / dedication text
    introduction.add_text (cookbook.intro_type==0 ? 'Introduction' : 'Dedication'),
      position: PdfCookbook.fpdf_y(18.mm+HC_PAGE_MARGIN[:top]), # +15.mm: in FPDF, margin only used to set the cursor origin, but coordinate are only relative to the top left corner
      font_style: PdfCookbook.fpdf_font_style(template.headers_font_style),
      font_size: template.headers_font_size.to_i,
      align: :center, 
      gap: HC_GAP,
      line_height: HC_LINE_HEIGHT,
      color: (cookbook.grayscale?) ? '000000' : PdfCookbook.fpdf_color(template.book_color),
      font: template.book_font

    introduction.add_text cookbook.intro_text,
      align: (cookbook.center_introduction) ? :center : :left,
      font_size: 11,
      line_height: HC_LINE_HEIGHT,
      gap: HC_GAP*2

    # Show the user intro image
    if cookbook.intro_image?
      introduction.add_image cookbook.image_path('intro_image'),
        mark_image_area: is_preview?
    end

    @document << introduction
  end

  # Add the notes page
  def add_notes_page(cookbook)

    # Build the note page
    note_page = PDFBook::Section.new page_number: true

    # Show the title
    note_page.add_text "Notes",
      position: PdfCookbook.fpdf_y(25.mm+HC_PAGE_MARGIN[:top]), # +15.mm: in FPDF, margin only used to set the cursor origin, but coordinate are only relative to the top left corner
      font_size: 17,
      align: :center,
      font_style: :italic,
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
      position: PdfCookbook.fpdf_y(175.mm),
      font_size: 9,
      align: :center,
      gap: 4.mm
    note_page.add_text 'www.HeritageCookbook.com',
      font_size: 11,
      align: :center, 
      gap: 4.mm,
      font_style: PdfCookbook.fpdf_font_style('BIU')
    note_page.add_text footer_notes.join("\n"),
      font_size: 9,
      align: :center,
      line_height: 4.mm

    @document << note_page
  end

  # Adds the table_of_contents page of a cookbook to the pdf document
  def add_table_of_contents(cookbook)
    template = cookbook.template

    # Build the Table of Content page
    toc_template = PDFBook::Section.new(
      background: cookbook.template.toc_image(cookbook.grayscale==1),
      background_size: :margin,
      page_margin_left: HC_COVER_MARGIN[:left],
      page_margin_right: HC_COVER_MARGIN[:right],
      page_margin_top: HC_COVER_MARGIN[:top],
      page_margin_bottom: HC_COVER_MARGIN[:bottom]+2.mm # Need to add ~2 mm to keep the same result as the old lib
    )

    # Show the title
    toc_template.add_text "Table of Contents",
      position: PdfCookbook.fpdf_y(template.toc_header_y.mm, true),
      align: :center, 
      color: (cookbook.grayscale?) ? "000000" : PdfCookbook.fpdf_color(template.book_color),
      font_style: PdfCookbook.fpdf_font_style(template.headers_font_style),
      font_size: template.headers_font_size.to_i,
      font: template.book_font

    # Configure the table of content
    @document.table_of_content_options(
      template: toc_template,
      width: HC_PAGE_WIDTH - (HC_COVER_MARGIN[:left]+28.mm+HC_COVER_MARGIN[:right]+28.mm), # '+28' is in the old lib
      position: PdfCookbook.fpdf_y(template.toc_header_y.mm + template.headers_font_size.to_i + 6.mm, true),
      start_at: 3 # The Cover and it's back does not count
    )

    @document << :table_of_content
  end   

  # Previews a section with all the recipes
  def add_section(section, cookbook, show_recipes=true, page_numbers=true)
    template = cookbook.template
    divider_image = (template.id == USER_CUSTOM_TEMPLATE_2_ID && section.photo?) ? section.pdf_image(mode) : template.divider_image(section.cookbook.grayscale==1)

    # Build the section page
    section_page = PDFBook::Section.new(
      background: divider_image,
      background_size: :margin,
      page_margin_left: HC_COVER_MARGIN[:left],
      page_margin_right: HC_COVER_MARGIN[:right],
      page_margin_top: HC_COVER_MARGIN[:top],
      page_margin_bottom: HC_COVER_MARGIN[:bottom]+2.mm, # Need to add ~2 mm to keep the same result as the old lib
      toc: section.name,
      must_be_right: PDFBook::Section.new(page_number: true)
    )

    if !(template.id == USER_CUSTOM_TEMPLATE_2_ID && section.photo?)

      # Show the section name
      section_page.add_text section.name,
        position: PdfCookbook.fpdf_y(template.section_header_y.mm+6.mm, true),
        align: :center,
        color: (section.cookbook.grayscale?) ? "000000" : PdfCookbook.fpdf_color(template.book_color),
        font_style: PdfCookbook.fpdf_font_style(template.headers_font_style),
        font_size: template.headers_font_size.to_i,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP,
        font: template.book_font

      # Show the user image for this section if exist
      if section.photo? 
        section_page.add_image section.pdf_image(mode),
          position: PdfCookbook.fpdf_y(template.section_user_image_y.mm+3.mm, true),
          max_width: template.section_user_image_max_width.mm,
          max_height: template.section_user_image_max_height.mm,
          mark_image_area: is_preview?
      end
    end

    # add_blank_page(true) if @document.pages % 2 == 1 # Sections page must always be right side
    @document << section_page

    # Add each recipes
    if show_recipes
      @start_recipe_in_new_page = true
      section.recipes.each do |recipe|
        add_recipe(recipe, page_numbers, false)
      end
    end
    
    # Add each extra pages
    section.extra_pages.each do |extra_page| 
      add_extra_page(extra_page, page_numbers)
    end
  end  

  # Adds a recipe to the pdf cookbook
  def add_recipe(recipe, page_numbers=true, force_new_page = false)

    # Build the main recipe page or get the last one and go to half page
    recipe_page = nil
    recipe_story_page = false
    if @start_recipe_in_new_page || force_new_page
      @new_section = true
      recipe_page = PDFBook::Section.new( 
        page_number: page_numbers,
        index: recipe.name
      )
    else
      @new_section = false
      recipe_page = @document.sections.last
      recipe_page.add_custom move_cursor_to: (HC_PAGE_HEIGHT - HC_PAGE_MARGIN[:top] - HC_PAGE_MARGIN[:bottom] ) /2 +5
      recipe_page.index = [recipe_page.index, recipe.name] # TODO: support multi index entry per page
    end

    # If this is a small recipe, start the next one on the same page
    if recipe.pages == 0.5
      @start_recipe_in_new_page = !@start_recipe_in_new_page
    end

    # Show the recipe in two pages format if it has a picture
    if !recipe.photo? #&& recipe.pages < 2.0
      add_recipe_title(recipe_page, recipe)
      add_recipe_story(recipe_page, recipe)
    else
      recipe_story_page = PDFBook::Section.new page_number: page_numbers
      add_recipe_story(recipe_story_page, recipe) 
      add_recipe_title(recipe_page, recipe)
    end

    # Show ingredients list
    if recipe.ingredients_uses_two_columns?
      column_options = {
        font_size: 11,
        line_height: HC_LINE_HEIGHT,
        gap: (!recipe.instructions.empty? || !recipe.servings.empty?) ? HC_GAP : false
      }
      recipe_page.add_column_text column_options, 
        recipe.ingredient_list, 
        recipe.ingredient_list_2
    else
      recipe_page.add_text recipe.ingredient_list,
        font_size: 11,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP
    end

    # Show recipe instructions
    recipe_page.add_text recipe.instructions,
        font_size: 11,
        line_height: HC_LINE_HEIGHT,
        gap: (!recipe.servings.empty?) ? HC_GAP/2 : false

    # Show recipe servings
    if !recipe.servings.to_s.empty?
      recipe_page.add_text recipe.servings,
        font_size: 11,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP/2
    end

    @document << recipe_story_page if recipe_story_page
    @document << recipe_page if @new_section
  end

  def add_recipe_title(recipe_page, recipe)

    # Show the recipe title
    recipe_page.add_text recipe.name,
      font_size: 17,
      font_style: PdfCookbook.fpdf_font_style('BI'),
      line_height: HC_LINE_HEIGHT,
      gap: (recipe.submitted_by.to_s.empty?) ? HC_GAP/2 : nil

    # Show the 'submitted_by' mention
    if !recipe.submitted_by.to_s.empty?
      recipe_page.add_text (recipe.submitted_by_title == '') ? recipe.submitted_by : "#{recipe.submitted_by_title} #{recipe.submitted_by}",
        font_size: 11,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP/2
    end
  end

  def add_recipe_story(recipe_page, recipe)

    # Show the recipe photo if exist
    if recipe.photo? && recipe.pdf_photo(mode)
      max_width = @document.page_width - ( @document.margin_options[:left_margin] + @document.margin_options[:right_margin] ) + 6.35.mm*2
      max_height = (@document.page_height - ( @document.margin_options[:top_margin] + @document.margin_options[:bottom_margin] ) - HC_GAP)
      if !recipe.story.empty?
        max_height = max_height / 2 + 10.mm
      end
      recipe_page.add_image recipe.pdf_photo(mode),
        max_width: max_width,
        max_height: max_height,
        gap: HC_GAP,
        mark_image_area: is_preview?
    end

    # Show the recipe story
    if recipe.story != ""
      recipe_page.add_text recipe.story,
        font_size: 11,
        line_height: HC_LINE_HEIGHT,
        gap: HC_GAP/2
    end
  end

  # Adds an add_extra_page to the pdf cookbook
  def add_extra_page(extra_page, page_numbers=true)

    # Create the extra page
    extra_recipe_page = PDFBook::Section.new( 
      page_number: page_numbers, 
      extra: (extra_page.index_as_recipe?) ? false : extra_page.name,
      index: (extra_page.index_as_recipe?) ? extra_page.name : false
      )

    # Show the title
    extra_recipe_page.add_text extra_page.name,
      font_size: 17,
      font_style: PdfCookbook.fpdf_font_style('BI'),
      gap: HC_GAP

    # Show the extra page image if exist
    if !extra_page.pdf_photo.blank?
      max_width = @document.page_width - ( @document.margin_options[:left_margin] + @document.margin_options[:right_margin] ) + 6.35.mm*2
      max_height = (@document.page_height - ( @document.margin_options[:top_margin] + @document.margin_options[:bottom_margin] ) - HC_GAP)
      if !extra_page.text.empty?
        max_height = max_height / 2 + 10.mm
      end
      extra_recipe_page.add_image extra_page.pdf_photo(mode),
        max_width: max_width,
        max_height: max_height,
        gap: HC_GAP,
        mark_image_area: is_preview?
    end

    # Show the extra page text
    extra_recipe_page.add_text extra_page.text,
      font_size: 11,
      line_height: HC_LINE_HEIGHT,
      gap: HC_GAP

    @document << extra_recipe_page
  end

  # Adds the book index to the PDF
  def add_index(cookbook, page_numbers=true)
    template = cookbook.template

    # Build the Index template page
    index_template = PDFBook::Section.new( 
      page_number: page_numbers,
      must_be_left: PDFBook::Section.new(page_number: true)
    )

    # Add the title
    index_template.add_text "Index",
      font_style: PdfCookbook.fpdf_font_style(template.headers_font_style),
      font_size: template.headers_font_size.to_i,
      line_height: HC_LINE_HEIGHT,
      gap: HC_GAP,
      font: template.book_font

    # Configure the document index system
    @document.index_options(
      template: index_template,
      start_at: 3,
      position: PdfCookbook.fpdf_y(60+HC_GAP)
    )

    @document << :index
  end

  # Adds the back cover to the PDF
  def add_back_cover(cookbook)
    template = cookbook.template

    # Build the back cover page
    back_cover = PDFBook::Section.new(
      page_margin_left: HC_COVER_MARGIN[:left],
      page_margin_right: HC_COVER_MARGIN[:right],
      page_margin_top: HC_COVER_MARGIN[:top],
      page_margin_bottom: HC_COVER_MARGIN[:bottom]+2.mm # Need to add ~2 mm to keep the same result as the old lib
    )
    
    # Add the cover image
    back_cover.add_image cookbook.template.back_cover_image, 
      max_height: 19.mm,
      position: 22.mm

    @document << back_cover
  end

  # FPDF output PDF file content using this method name.
  def Output
    @document.to_pdf
  end

  # Build index entries for a cookbook without adding pages.
  # This is used for index preview and index lenght calculator.
  def build_fake_index(cookbook)

    # PDF book toc, index and extras will be entered manually to add entries to the index
    @document.toc = {}
    @document.index = {}
    @document.extras = {}

    sections = cookbook.sections

    sections.each_index do |section_index|
      section_counter = 1
      if sections[section_index].has_children?
        recipes = sections[section_index].recipes
        extra_pages = sections[section_index].extra_pages

        @document.toc["#{sections[section_index].name}"] = "#{section_index+1}00}".to_i

        recipes.each_index do |recipe_index|
          @document.index["#{recipes[recipe_index].name}"] = "#{section_index+1}#{format('%02d', section_counter)}".to_i
          section_counter += 1
        end

        extra_pages.each_index do |extra_index|
          if extra_pages[extra_index].index_as_recipe?
            @document.index["#{extra_pages[extra_index].name}"] = "#{section_index+1}#{format('%02d', section_counter)}".to_i
          else
            @document.extras["#{extra_pages[extra_index].name}"] = "#{section_index+1}#{format('%02d', section_counter)}".to_i
          end
          section_counter += 1
        end
      end
    end
  end

  private

  def is_preview?
    !@final_mode
  end
  
  def mode
    is_preview? ? 'preview' : 'final'
  end

  # FPDF (library used by the old script) use the left-top corner of the page as origin.
  # Prawn use the left-bottom corner of the bounding box as origin.
  # This method return the Prawn coordinate corresponding to an FPDF coordinate,
  # or the return FPDF coordinate corresponding to a Prawn coordinate.
  def self.fpdf_y(y, cover=false)
    if cover
      return HC_PAGE_HEIGHT - HC_COVER_MARGIN[:bottom] - y
    else
      return HC_PAGE_HEIGHT - HC_PAGE_MARGIN[:bottom] - y
    end
  end

  # 1 pt (Prawn mesurement) = 2.834645669291339 mm
  def self.pt2mm(pt)
    mm=2.834645669291339
    return pt / mm
  end

  # TODO: support multi style
  def self.fpdf_font_style(font_style)
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

  def self.int2hex(int)
    if int < 16
      return "0#{int.to_s(16)}"
    else
      return int.to_s(16)
    end
  end

  def self.fpdf_color(color)
    rgb = color.split(',')
    return "#{PdfCookbook.int2hex(rgb[0].to_i)}#{PdfCookbook.int2hex(rgb[1].to_i)}#{PdfCookbook.int2hex(rgb[2].to_i)}"
  end

end