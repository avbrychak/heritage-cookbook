require 'prawn'
require 'open-uri'
require 'tmpdir'

# Note: On how Prawn manage margin box when `go_to_page` happens
# When a `go_to_page` happens, prawn do not know the margin box of the called page, it use the last 
# one it used (the margin box of the page it was before the goto call). 
# On index, toc page and for page numbers, it use the margin box of the last page of the document (the back cover).
# In the future, we can fix this recreating a bounding box using the stored margin (@index_page.page_margins for index) or
# using absolute positionning (unsing a Prawn `canvas`).
# See: https://github.com/prawnpdf/prawn/issues/272
class PDFBook::Document

  attr_accessor :sections, :index, :extras, :toc
  attr_reader :page_width, :page_height, :margin_options, :pdf, :last_position 

  def initialize(options={})

    # Page size
    @page_size = options[:page_size] || 'LETTER'
    if @page_size.class == String
      @page_width = Prawn::Document::PageGeometry::SIZES[@page_size][0].to_f
      @page_height = Prawn::Document::PageGeometry::SIZES[@page_size][1].to_f
    else
      @page_width = @page_size[0].to_f
      @page_height = @page_size[1].to_f
    end

    # Page margins
    @margin_options = {
      top_margin: options[:page_margin_top] || 0.5,
      bottom_margin: options[:page_margin_bottom] || 0.5,
      left_margin: options[:page_margin_left] || 0.5,
      right_margin: options[:page_margin_right] || 0.5
    }

    # Fonts
    @font = options[:font] || 'Times-Roman'
    
    # Book content
    @sections = []
    @toc = {}
    @index = {}
    @extras = {}
    @page_number = []

    # Watermark
    @watermark ||= options[:watermark]

    # Layout (:book or :document, :document is the default)
    @layout = options[:layout] || :document

    build_document
  end

  # Add custom font families to the document
  def font_families=(font_families)
    @font_families = font_families
    update_font_families
  end

  # Add PDFBook::Section or special sym (:index, :table_of_content)
  def <<(section)
    self.sections << section
  end

  # Configure the Table of Content
  def table_of_content_options(options={})
    @toc_template   = options[:template] || PDFBook::Section.new
    @toc_position   = options[:position] || @pdf.bounds.top
    @toc_width      = options[:width]    || @pdf.bounds.width
    @toc_start_at   = options[:start_at] || 1
    @use_old_layout = (options[:layout] == :old)
  end

  # Configure the Index
  def index_options(options={})
    @index_template = options[:template] || PDFBook::Section.new
    @index_position = options[:position] || @pdf.bounds.top
    @index_width    = options[:width]    || @pdf.bounds.width
  end

  # Render the document in a sandbox and return the page number
  def pages
    page_count = 0

    # If the document is not rendered yet
    if @pdf.page_count == 0
      sandbox do
        render
        page_count = @pdf.page_count
      end
    else
      page_count = @pdf.page_count
    end

    return page_count
  end

  # Export the document to PDF (Stream)
  def to_pdf
    render
    @pdf.render
  end

  # Export the document to PDF (File)
  def to_file(path)
    render
    @pdf.render_file path
  end

  # Render the document
  # Limitation: must_be_left & must_be_left and page numbers, will be false if toc or index > 1 page.
  def render

    # Render each sections
    sections.each do |section|
      case section
      when :table_of_content

        # Create empty pages, content will be insered later
        table_of_content_options if !@toc_template
        add_page_if_needed(@toc_template)
        init_new_page(@toc_template.margin_options)
        @toc_page = @pdf.page_count
      
      when :index

        # Create empty pages, content will be insered later
        index_options if !@index_template
        add_page_if_needed(@index_template)
        init_new_page(@index_template.margin_options)
        @index_page = @pdf.page_count
      else
        raise TypeError, "#{section.class} is not PDFBook::Section" if section.class != PDFBook::Section
        if section.vertical_align == :center
          section_height = calc_section_height section
          if section_height
            origin_padding_top = ((@page_height - @margin_options[:top_margin] - @margin_options[:bottom_margin]) - section_height) /2
            init_new_page(section.margin_options)
            @pdf.move_down origin_padding_top
          end
          render_section section, !section_height
        else
          render_section section
        end
      end
    end

    # Render the Table of Content
    if @toc_page
      if @use_old_layout
        render_old_table_of_content
      else
        render_table_of_content
      end
    end

    # Count the index pages and render the index
    if @index_page && @index_template
      index_page_count = 1
      sandbox do
        init_new_page(@index_template.margin_options)
        @index_page = 1
        render_index
        index_page_count = @pdf.page_count
      end
      render_index(index_page_count)
    end

    # Print the page numbers
    @pdf.canvas do
      position = @margin_options[:bottom_margin]
      @pdf.number_pages "— <page> —",
        at: [0, 30],
        align: :center,
        size: 11,
        page_filter: @page_number,
        start_count_at: @toc_start_at
    end

    return true
  end

  private

  # Get accurate page number.
  # This is calculated using the start_at and the first numbered page.
  def get_accurate_page_number(number)
    toc_start_at = @toc_start_at || 1
    if @page_number.empty? 
      return number + toc_start_at - 1
    else 
      return number - @page_number.first + toc_start_at
    end
  end

  # Initialize the PDF
  def build_document
    @pdf = Prawn::Document.new(
      page_size: @page_size,
      skip_page_creation: true
    )

    # Patch Prawn to ouput PDF with the correct layout metadata (open in two page mode with odd page right and zoom to 100%)
    @pdf.instance_eval{ @internal_state.store.root.data[:OpenAction] = [@internal_state.store.root.data[:Pages], :XYZ, 0, 0, 1] }
    if @layout == :book
      @pdf.instance_eval{ @internal_state.store.root.data[:PageLayout] = :TwoPageRight }
    else
      @pdf.instance_eval{ @internal_state.store.root.data[:PageLayout] = :TwoPageLeft }
    end

    # Add custom font families if exist
    update_font_families

    # Watermark
    if @watermark
      @pdf.create_stamp("watermark") do
        @pdf.fill_color "D2D2D2"
        @pdf.text_box @watermark,
          :size   => 3.8.cm,
          :width  => 9.4.in,
          :height => @pdf.bounds.height,
          :align  => :center,
          :valign => :center,
          :at     => [-(9.in-@pdf.bounds.width)/2, @pdf.bounds.height],
          :rotate => 60,
          :rotate_around => :center
      end
    end
  end

  # Update Prawn font families
  def update_font_families
    @pdf.font_families.update @font_families if @font_families
  end

  # Work in a sandbox (nothing will affect the real document).
  def sandbox(&block)

    # Backup current state
    backup = {}
    backup[:pdf]            = @pdf
    backup[:index_template] = @index_template
    backup[:toc_template]   = @toc_template
    backup[:page_number]    = @page_number
    backup[:index_page]     = @index_page
    backup[:toc_page]       = @toc_page
    
    # Recreate a new temporary PDF to work with
    build_document
    if backup[:index_template]
      @index_template = PDFBook::Section.new(
        must_be_right: backup[:index_template].must_be_right, 
        must_be_left: backup[:index_template].must_be_left
      )
    end
    if backup[:toc_template]
      @toc_template = PDFBook::Section.new(
        must_be_right: backup[:toc_template].must_be_right, 
        must_be_left: backup[:toc_template].must_be_left
      )
    end
    block.call

    # Restore old state
    @pdf            = backup[:pdf]
    @index_template = backup[:index_template]
    @toc_template   = backup[:toc_template]
    @page_number    = backup[:page_number]
    @index_page     = backup[:index_page]
    @toc_page       = backup[:toc_page]
  end

  # Add a new page to the PDF document
  def init_new_page(new_margin_options={})
    @pdf.start_new_page @margin_options.merge(new_margin_options)
    @pdf.font(@font)
    @pdf.stamp "watermark" if @watermark
  end

  # Add page if section.must_be_left or section.must_be_right
  def add_page_if_needed(section)
    
    # The first page must always be right
    if section.must_be_right
      render_section section.must_be_right if @pdf.page_count % 2 == 1

    # The first page must always be left
    elsif section.must_be_left
      render_section section.must_be_left if @pdf.page_count % 2 == 0
    end
  end

  # Render the index
  def render_index(index_page_count=nil)

    # Add missing pages if the index take more than one page
    if index_page_count
      @pdf.go_to_page @index_page if @index_page > 0
      (index_page_count-1).times do
        init_new_page(@index_template.margin_options)
      end
    end
  
    # Build a Hash of topic and associed subtopics ordered by page numbers
    ordered = {} 
    @toc.each{ |label, page| ordered["#{label}"] = {page: page, subtopics: {}, extras: {}}}
    last_ordered_topic_key = ordered.keys.last
    @index.each do |label, page|
      last_topic = {label: ordered.first[0], page: ordered.first[1][:page]}
      ordered.each do |topic_label, topic_attributes|
        if page > last_topic[:page] && page < topic_attributes[:page]
          ordered["#{last_topic[:label]}"][:subtopics]["#{label}"] = {page: page}
        elsif page > last_topic[:page] && topic_label == last_ordered_topic_key
          ordered["#{last_ordered_topic_key}"][:subtopics]["#{label}"] = {page: page}
        end
        last_topic = {label: topic_label, page: topic_attributes[:page]}
      end
    end
    @extras.each do |label, page|
      last_topic = {label: ordered.first[0], page: ordered.first[1][:page]}
      ordered.each do |topic_label, topic_attributes|
        if page > last_topic[:page] && page < topic_attributes[:page]
          ordered["#{last_topic[:label]}"][:extras]["#{label}"] = {page: page}
        elsif page > last_topic[:page] && topic_label == last_ordered_topic_key
          ordered["#{last_ordered_topic_key}"][:extras]["#{label}"] = {page: page}
        end
        last_topic = {label: topic_label, page: topic_attributes[:page]}
      end
    end

    # Order topics by names and display them
    topic_size=11
    subtopic_size = 11
    @index_template.add_custom move_cursor_to: @index_position
    ordered.sort_by{|label, attributes| label}.each do |label, parameters|

      # 'Start at' modificateur
      parameters[:page] = get_accurate_page_number(parameters[:page])

      # Display topic
      space_width = @pdf.width_of(" ", size: topic_size, font: @font)
      label_width = @pdf.width_of(label.upcase, size: topic_size, font: @font)
      page_number_width = @pdf.width_of(parameters[:page].to_s, size: topic_size, font: @font)
      space_number = (@pdf.bounds.width - label_width - page_number_width) / space_width
      @index_template.add_custom(
        line_width: 0.5,
        text: [ 
          "#{label.upcase} <u>#{" "*(space_number-2)}</u> #{parameters[:page]}", 
          size: topic_size,
          inline_format: true,
          leading: 2
        ]
      )

      # Order subtopics by name and display them
      parameters[:subtopics].sort_by{|subtopic_label, subtopic_parameters| subtopic_label}.each do |subtopic_label, subtopic_parameters|

        # 'Start at' modificateur
        subtopic_parameters[:page] = get_accurate_page_number(subtopic_parameters[:page])

        # Clean out page number from the name of the label
        # label of 'My extra page{{159}}' will becomne 'My extra page'
        subtopic_label = subtopic_label.sub /{{.*}}/, ''

        # Display subtopic
        @index_template.add_custom(
          text: [ 
            "#{subtopic_label}, #{subtopic_parameters[:page]}", 
            size: subtopic_size,
            leading: 2
          ]
        )
      end

      @index_template.add_custom move_down: 0.215.in

      # Order extras by name amd display them
      if !parameters[:extras].empty?
        parameters[:extras].sort_by{|extra_label, extra_parameters| extra_label}.each do |extra_label, extra_parameters|

          # Clean out page number from the name of the label
          # label of 'My extra page{{159}}' will becomne 'My extra page'
          extra_label = extra_label.sub /{{.*}}/, ''

          # 'Start at' modificateur
          extra_parameters[:page] = get_accurate_page_number(extra_parameters[:page])

          # Display extra
          @index_template.add_custom(
            text: [ 
              "#{extra_label}, #{extra_parameters[:page]}", 
            size: subtopic_size,
            leading: 2
            ]
          )
        end
        @index_template.add_custom move_down: 0.215.in
      end
    end

    @pdf.go_to_page @index_page if @index_page > 0

    # Prawn lose the page margins using goto, use a bounding box to fix that
    @pdf.canvas do
      origin = [@index_template.margin_options[:left_margin] || @margin_options[:left_margin], @page_height - (@index_template.margin_options[:top_margin] || @margin_options[:top_margin])]
      width = @page_width - (@index_template.margin_options[:left_margin] || @margin_options[:left_margin]) - (@index_template.margin_options[:right_margin] || @margin_options[:right_margin])
      height = @page_height - (@index_template.margin_options[:top_margin] || @margin_options[:top_margin]) - (@index_template.margin_options[:bottom_margin] || @margin_options[:bottom_margin])
      @pdf.bounding_box(origin, width: width, height: height) do

        render_section @index_template, false
      end
    end
  end

  # Render the Table of Content the old way (old layout)
  def render_old_table_of_content
    toc_font_size = 11
    cells = []
    @toc.sort_by{|label, page| page}.each do |label, page|

      # 'Start at' parameter
      page = get_accurate_page_number(page)

      label_cell = @pdf.make_cell(content: label.to_s, size: toc_font_size, font: @font)
      page_cell = @pdf.make_cell(content: page.to_s, size: toc_font_size, font: @font)
      page_cell.align = :right
      cells << [label_cell, page_cell]
    end

    if !cells.empty?
      @toc_template.add_custom(
        move_cursor_to: @toc_position,
        table: [
          cells,
          width: @toc_width,
          cell_style: { borders: []},
          position: :center
        ]
      )
    end
    @pdf.go_to_page @toc_page if @toc_page > 0

    # Prawn lose the page margins using goto, use a bounding box to fix that
    @pdf.canvas do
      origin = [@toc_template.margin_options[:left_margin] || @margin_options[:left_margin], @page_height - (@toc_template.margin_options[:top_margin] || @margin_options[:top_margin])]
      width = @page_width - (@toc_template.margin_options[:left_margin] || @margin_options[:left_margin]) - (@toc_template.margin_options[:right_margin] || @margin_options[:right_margin])
      height = @page_height - (@toc_template.margin_options[:top_margin] || @margin_options[:top_margin]) - (@toc_template.margin_options[:bottom_margin] || @margin_options[:bottom_margin])
      @pdf.bounding_box(origin, width: width, height: height) do
        render_section @toc_template, false
      end
    end
  end

  # Render the Table of Content
  def render_table_of_content
    toc_font_size = 11
    cells = []
    @toc.sort_by{|label, page| page}.each do |label, page|

      # 'Start at' parameter
      page = get_accurate_page_number page

      label_cell = @pdf.make_cell(content: label.upcase.to_s, font: @font, size: toc_font_size, font_style: :bold)
      page_cell = @pdf.make_cell(content: page.to_s, size: toc_font_size, font: @font, font_style: :normal)
      page_cell.align = :right
      cells << [page_cell, label_cell]
    end

    if !cells.empty?
      @toc_template.add_custom(
        move_cursor_to: @toc_position,
        table: [
          cells,
          width: @toc_width,
          cell_style: { borders: []},
          position: :center,
          column_widths: {0 => 1.125.in}
        ]
      )
    end
    @pdf.go_to_page @toc_page if @toc_page > 0

    render_section @toc_template, false
  end

  # Render a section
  def render_section(section, new_page=true)
    if new_page
      if section.must_be_right

        # Section first page must always be right
        render_section section.must_be_right if @pdf.page_count % 2 == 1
      elsif section.must_be_left

        # Section first page must always be left
        render_section section.must_be_left if @pdf.page_count % 2 == 0
      end
    end

    init_new_page(section.margin_options) if new_page == true
    section_first_page = @pdf.page_number

    # Vertically centred
    @pdf.move_down @origin_padding_top if @origin_padding_top

    # Register the section in the ToC
    if section.toc
      @toc[section.toc] = @pdf.page_count
    end

    # Register the section in the Index
    # Build the label using provided index name and page count
    # ex: 'Recipe 1' page 118 => 'Recipe 1{{118}}' to allow duplicated index names
    if section.index
      case section.index
      when Array
        section.index.each do |entry|
          @index["#{entry}{{#{@pdf.page_count}}}"] = @pdf.page_count
        end
      when String
        @index["#{section.index}{{#{@pdf.page_count}}}"] = @pdf.page_count
      end
    end

    # Register the section in the Index as Extra
    # Build the label using provided index name and page count
    # ex: 'Recipe 1' page 118 => 'Recipe 1{{118}}' to allow duplicated index names
    if section.extra
      @extras["#{section.extra}{{#{@pdf.page_count}}}"] = @pdf.page_count
    end

    # Insert the section background if exist
    if section.background
      if !PDFBook::Helpers.raise_error_if_image_not_found(section.background)
        case section.background_size
        when :fullpage
          open(section.background) do |image|
            @pdf.image image,
              at: [-@pdf.bounds.absolute_left, @page_height - @pdf.bounds.absolute_bottom],
              width: @page_width,
              height: @page_height
          end
        when :margin
          open(section.background) do |image|
            @pdf.image image, 
              fit: [@pdf.bounds.width, @pdf.bounds.height], 
              position: :center,
              vposition: :center
          end
          @pdf.move_cursor_to @pdf.bounds.height
        end
      end
    end

    # Insert the section content
    section.contents.each do |content|
      case content

      when PDFBook::Content::Custom
        content.data.each do |command, args|
          @pdf.stroke do
            (args) ? @pdf.send(command, *args) : @pdf.send(command)
          end
        end

      # Replace tabs (\t) with spaces to not print square.
      when PDFBook::Content::Text
        @pdf.font content.font || @font do
          @pdf.move_cursor_to content.position if content.position
          @pdf.text content.data, 
            align: content.align, 
            size: content.font_size, 
            style: content.font_style, 
            leading: content.line_height,
            color: content.color,
            inline_format: true
          @pdf.move_down content.gap if content.gap
        end

      when PDFBook::Content::ColumnText
        @pdf.table [content.data], 
          width: @pdf.bounds.width, 
          cell_style: { borders: [], size: content.font_size, leading: content.line_height, padding: 4, font: @font, font_style: content.font_style}
        @pdf.move_down content.gap if content.gap

      when PDFBook::Content::Image
        if content.data
          @pdf.move_cursor_to content.position if content.position
          max_width = content.max_width || @pdf.bounds.width
          max_height = content.max_height || @pdf.cursor
          image_origin = [(@pdf.bounds.width-max_width)/2, @pdf.cursor]

          begin

            # PNG can kill server ressources, always convert them to jpg
            raise Prawn::Errors::UnsupportedImageType if content.type == :png
            
            open(content.data) do |image|

              # Fit max_width and max_height if image > image area
              # Else just center the image
              if content.width >= max_width || content.height >= max_height
                @pdf.image(image, fit: [max_width, max_height], position: :center)
              else
                @pdf.image(image, position: :center)
              end
            end
          
          # If image is not in a supported format, convert it to JPG
          rescue Prawn::Errors::UnsupportedImageType
            content.data = convert_to_jpg content.data
            content.type = :jpg
            retry
          end
          # if content.width > max_width || content.height > max_height
          #   @pdf.image(open(content.data), fit: [max_width, max_height], position: :center)
          # else
          #   @pdf.image(open(content.data), position: :center)
          # end

          if content.mark_image_area
            @pdf.line_width(2)
            @pdf.stroke_rectangle(image_origin, max_width, max_height)
            @pdf.line_width(1)
          end
          @pdf.move_down content.gap if content.gap
        end

      else
        raise TypeError, "This content (#{content.class}) is not allowed"
      end

      record_last_position
    end
    @page_number += (section_first_page..@pdf.page_number).to_a if section.page_number
  end

  # Record the last know y position in the last page with content
  # The position is relative to the page, not the bounding box (y vs cursor)
  def record_last_position
    @last_position = @pdf.y
  end

  # Calculate the section height
  def calc_section_height(section)
    height = false
    sandbox do
      init_new_page(section.margin_options)
      start = @pdf.cursor
      render_section section, false
      stop = @pdf.cursor
      height = start - stop if @pdf.page_count == 1
    end
    return height
  end

  # Convert an image into a jpg format, need imagemagick
  def convert_to_jpg(path)
    tmpdir    = Dir.mktmpdir
    extension = File.extname(path)
    filename  = File.basename(path).gsub(/#{extension}$/, '.jpg')
    `convert "#{path}"[0] "#{tmpdir}/#{filename}"`
    return "#{tmpdir}/#{filename}"
  end
end