module PaperclipImageExtensions

  # Downgrade the image DPI if more than 300 pixels per inch
  def convert_dpi(attribute)
    max_dpi = 300
    original = self.send(attribute).queued_for_write[:original]
    if original
      image_path = original.path
      image = HeritageImage.new image_path

      if image.dpi > max_dpi
        image.dpi = max_dpi
        File.open(image.path) do |file|
          self.send "#{attribute}=", file
        end
      end
    end
  end

  # Write the image dimensions and DPI for the given Paperclip attribute
  def image_dimensions(attribute)
    original = self.send(attribute).queued_for_write[:original]
    if original
      image_path = original.path
      image = HeritageImage.new image_path
      self.send "#{attribute}_dpi=", image.dpi
      self.send "#{attribute}_width=", image.width
      self.send "#{attribute}_height=", image.height
    end
  end
end