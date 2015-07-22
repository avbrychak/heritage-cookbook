require 'fastimage'
require 'open-uri'

module PDFBook::Content

  # Custom Prawn content
  class Custom
    attr_accessor :data

    def initialize(commands)
      @data = commands
    end
  end
  
  # Text content
  class Text

    attr_accessor :data, :position, :align, :font_size, :font_style, :line_height, :color, :gap, :font

    # Replace tab with space and replace space with non-breaking spaces
    def initialize(text, options={})

      # Default the text to an empty string if nil
      text = "" if !text

      # Replace all tab with four non-breaking spaces
      text.gsub!("\t", "\u00A0\u00A0\u00A0\u00A0")

      # Replace leading white spaces with non-breaking spaces.
      # Prawn remove leading white space, we want to keep them.
      clean_text = ""
      text.each_line do |line|
        scan = line.scan(/^\s*/)
        leading_space_number = (scan.empty?) ? false : line.scan(/^\s*/).first.size
        clean_text += line.sub(/^ */, "\u00A0" * leading_space_number) if leading_space_number
      end
      text = clean_text

      # Remove space between a line break (\r\n) to ensure Prawn will not add a linebreak if the line it 
      # write minus the ending space take the full document width. In this case the cursor will go to the 
      # new line just to print the space.
      text.gsub!(/\s*$/, "")

      @data = text if text
      @position ||= options[:position]
      @align = options[:align] || :left
      @font_size = options[:font_size] || 12
      @font_style = options[:font_style] || :normal
      @line_height = options[:line_height] || 0
      @color = options[:color] || "000000"
      @gap ||= options[:gap]
      @font ||= options[:font]
    end
  end

  # Text content in two column
  class ColumnText

    attr_accessor :data, :font_size, :line_height, :gap, :font_style

    def initialize(options={}, *texts)
      @data = []
      @font_size = options[:font_size] || 12
      @font_style = options[:font_style] || :normal
      @line_height = options[:line_height] || 0
      @gap ||= options[:gap]
      texts.each do |text|
        
        # Default the text to an empty string if nil
        text = "" if !text
        
        # Replace all tab with four non-breaking spaces
        text.gsub!("\t", "\u00A0\u00A0\u00A0\u00A0")

        # Replace leading white spaces with non-breaking spaces.
        # Prawn remove leading white space, we want to keep them.
        clean_text = ""
        text.each_line do |line|
          scan = line.scan(/^\s*/)
          leading_space_number = (scan.empty?) ? false : line.scan(/^\s*/).first.size
          clean_text += line.sub(/^ */, "\u00A0" * leading_space_number) if leading_space_number
        end
        text = clean_text
        
        @data << text
      end
    end
  end

  # Image content
  class Image

    attr_accessor :data, :width, :height, :max_width, :max_height, :position, :gap, :mark_image_area, :type

    def initialize(path, options={})
      if !PDFBook::Helpers.raise_error_if_image_not_found(path)
        @type = FastImage.type(path)
        
        @data = path
        begin
          @width, @height = FastImage.size(path, raise_on_failure: true, timeout: 120)
        rescue FastImage::ImageFetchFailure
          raise "FastImage::ImageFetchFailure - #{path}"
        end
        @mode = (@width > @height) ? :landscape : :portrait
        @ratio = @width / @height

        @position ||= options[:position]
        @max_width ||= options[:max_width]
        @max_height ||= options[:max_height]
        @gap ||= options[:gap]
        @mark_image_area ||= options[:mark_image_area]
      end
    end
  end
end