class PdfExtensions < FPDF

  # require 'RMagick'
  # require 'iconv'
  # require 'pdf_extensions'
  require 'open-uri'

  # include Magick
  # include Reloadable
  # include CustomLogger

  # Predefined document values
  # Measurements in millimeters
  HC_PAGE_HEIGHT = 228.6  
  HC_PAGE_WIDTH = 152.4  
  HC_ODD_MARGIN = {:top => 15, :right => 19.05, :left => 19.05, :bottom => 20}   # Right page
  HC_EVEN_MARGIN = {:top => 15, :right => 19.05, :left => 19.05, :bottom => 20}   # Left page
  HC_COVER_MARGIN = {:top => 13, :right => 13, :left => 13, :bottom => 15} 
  HC_LINE_HEIGHT = 4.65  

  PDF_DEBUG = false
  
  attr_accessor :col, :y_pos
  
  # Creates a new pdf document with some default values
  def initialize(final_mode=false)
    super('P', 'mm', [HC_PAGE_WIDTH, HC_PAGE_HEIGHT]) # Portrait mode, millimeters, width/height
    SetDisplayMode('fullpage', 'tworight')
    @final_mode = final_mode
  end

  def is_preview?
    !@final_mode
  end
  
  def mode
    is_preview? ? 'preview' : 'final'
  end

  def max_usable_height
    HC_PAGE_HEIGHT - @margin[:top] - @margin[:bottom]
  end

  def max_usable_width
    HC_PAGE_WIDTH - @margin[:left] - @margin[:right]
  end

  def max_usable_height_remaining
    HC_PAGE_HEIGHT - GetY() - @margin[:bottom]
  end

  # Writes a line of text followed by an empty line
  def write_text(text, centered=false, line_height=HC_LINE_HEIGHT, space_after = true)
    return if text.to_s.empty?

    # the extra "- 1" in there is a "fudge factor" as things don't seem to be exactly centered without it
    SetX(@margin[:left]+(max_usable_width/2)-(GetStringWidth(text)/2)-1) if centered 

    Write(line_height, clean_text(text))
    Ln()
    
    # don't re-indent this please. Everything is at stake here
    if space_after
      Write(line_height, '
') 
      SetX(@margin[:left]+(max_usable_width/2)-(GetStringWidth(text)/2)-1) if centered 
    end
  end


  # Add a blank page
  def add_blank_page
    new_page(true, false)
  end
  
  # Displays a centered image at the current coordinates
  def show_centered_image(filename, width, height, show_box=false)
    filename.gsub!(/\?\d*$/, '') # Removes extra question mark and any digits after the filename
    img_geometry = Paperclip::Geometry.from_file(filename)

    # Center the box horizontally by moving X if the box is smaller than the page
    SetX(GetX()+(max_usable_width-width)/2) if width < max_usable_width

    if ((img_geometry.height*width)/img_geometry.width > height)
      # Center the image horizontaly
      img_width = (img_geometry.width*height)/img_geometry.height
      Image(filename, GetX()+(width-img_width)/2, GetY(), img_width)
      img_height = height
    else
      # Align image on top
      Image(filename, GetX(), GetY(), width)
      img_height = img_geometry.height*width/img_geometry.width
    end

    rectangle(GetX(), GetY(), GetX()+width, GetY()+height, show_box)
    SetY(GetY() + img_height+HC_LINE_HEIGHT)
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError
    # The image doesn't exist, so don't show it
  end

  # Draws a rectangle with a diagonal line across
  def rectangle(x1, y1, x2, y2, show_user_box=false)
    if PDF_DEBUG || (show_user_box && is_preview?)
      SetLineWidth(0.6)
      Line(x1, y1, x2, y1)
      Line(x2, y1, x2, y2)
      Line(x2, y2, x1, y2)
      Line(x1, y2, x1, y1)
      SetLineWidth(0.2)
      Line(x1, y1, x2, y2) if PDF_DEBUG # The diagonal line
    end
  end


  # Adds a new page to the pdf document
  def new_page(cover_page=false, page_number=true)
    # These variables will be used by the Header function
    @cover_page = cover_page
    @page_number = page_number
    AddPage()
  end


  # Show a watermark on every page
  def show_watermark
    line_height = 27
    left = @margin[:left]
    increment = 10
    SetY(@margin[:top])

    SetTextColor(230,230,230)
    SetFont('Times','',70)                                                                               
    str = %w[P R E V I E W].each do |letter|
      Write(line_height, letter)
      Ln()
      SetX(left+=increment)
    end
    Ln()
    SetY(@margin[:top])
    SetTextColor(0,0,0)
  end

  # This code will be executed every time a page is created
  def Header
    # Select what margin we should use
    if @cover_page
      @margin = HC_COVER_MARGIN
    else        
      @margin = PageNo() % 2 == 0 ? HC_EVEN_MARGIN : HC_ODD_MARGIN
    end           
    SetMargins(@margin[:left], @margin[:top], @margin[:right])
    SetAutoPageBreak(true, @margin[:bottom])
    SetTextColor(0, 0, 0)    
    SetY(@margin[:top])

    # Show the page boundaries - for debug purposes
    rectangle(@margin[:left], @margin[:top], HC_PAGE_WIDTH-@margin[:right], HC_PAGE_HEIGHT-@margin[:bottom])

    # Check if we want to show the watermark on the page
    show_watermark if is_preview?

    # Check if we want to show the page number                 
    if @page_number
      SetAutoPageBreak(false)
      SetFont('Times','',12)  
      SetY(-10)
      write_text((PageNo()-2).to_s, true)
      SetAutoPageBreak(true, @margin[:bottom])
      SetY(@margin[:top])
    end
  end

  # This is being overriden to add the TwoColumnRight format
  def SetDisplayMode(zoom, layout='continuous')
    # Set display mode in viewer
    if zoom=='fullpage' or zoom=='fullwidth' or zoom=='real' or
      zoom=='default' or not zoom.kind_of? String
      @ZoomMode=zoom;
    elsif zoom=='zoom'
      @ZoomMode=layout
    else
      raise 'Incorrect zoom display mode: '+zoom
    end
    
    if layout=='single' or layout=='continuous' or layout=='two' or
      layout=='default' or layout=='tworight'
      @LayoutMode=layout
    elsif zoom!='zoom'
      raise 'Incorrect layout display mode: '+layout
    end
  end

  # This is being overriden to add the TwoColumnRight format
  def putcatalog
    out('/Type /Catalog')
    out('/Pages 1 0 R')
    if @ZoomMode=='fullpage'
      out('/OpenAction [3 0 R /Fit]')
    elsif @ZoomMode=='fullwidth'
      out('/OpenAction [3 0 R /FitH null]')
    elsif @ZoomMode=='real'
      out('/OpenAction [3 0 R /XYZ null null 1]')
    elsif not @ZoomMode.kind_of?(String)
      out('/OpenAction [3 0 R /XYZ null null '+(@ZoomMode/100)+']')
    end

    if @LayoutMode=='single'
      out('/PageLayout /SinglePage')
    elsif @LayoutMode=='continuous'
      out('/PageLayout /OneColumn')
    elsif @LayoutMode=='two'
      out('/PageLayout /TwoColumnLeft')
    elsif @LayoutMode=='tworight'
      out('/PageLayout /TwoColumnRight') 
    end
  end

end