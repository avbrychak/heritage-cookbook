class HeritageImage

	attr_accessor :path

  def initialize(path)
  	@path = path
  end

  def dpi
  	@dpi ||= `identify -units PixelsPerInch -format "%x" "#{@path}"`.match(/\d+/).to_s.to_i
  end

  def width
    @width ||= `identify -format "%w" "#{@path}"`.to_i
  end

  def height
    @height ||= `identify -format "%h" "#{@path}"`.to_i
  end

  def dpi=(ppi)
  	if ppi != dpi
	  	new_image = Tempfile.new(['ppi', '.jpg'])
      `convert -units PixelsPerInch -strip "#{@path}" -resample #{ppi} "#{new_image.path}"`
	  	@path = new_image.path
	  end
	  return ppi
  end

  # Calculate a "virtual dpi" if image was resampled to the given dimensions in pixels
  # We want to be able to accept images with low dpi but hight dimensions
  def vdpi(max_width, max_height)
    width_resolution = dpi * width / [max_width, width].min
    height_resolution = dpi * height / [max_height, height].min
    return (width > height) ? width_resolution : height_resolution
  end
end