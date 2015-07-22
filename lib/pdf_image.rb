class PdfImage
  
  # 6x9 inch in 300dpi
  def self.final_image_max_size
    '1800x2700>'
  end

  # Should be '432x648>' to ensure full-width or full-height image in templates
  # '432x648>' is 6x9 inch in 72dpi
  def self.preview_image_max_size
    '432x648>'
  end
  
  def self.convert(operation, src, dst=nil)
    src.gsub!(/\?\d*$/, '') # Removes extra question mark and any digits after the filename
    dst ||= src
    
    transformation_command = case operation
    when :grayscale 
      '-colorspace Gray'
    when :resize 
      "-scale \"#{PdfImage.preview_image_max_size}\""
    end
    
    command = <<-end_command
      #{[Paperclip.options[:command_path], 'convert'].compact.join}
      "#{ src }[0]"
      #{ transformation_command } -density 200
      "#{ dst }"
    end_command
    success = system(command.gsub(/\s+/, " "))
  end
end