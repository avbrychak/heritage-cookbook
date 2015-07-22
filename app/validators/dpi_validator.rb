# Validate an image DPI/PPI using imagemagick utility 'identify'
# Also update the DPI attribute of the model instance
class DpiValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)

    # Error if DPI is too low
    if options[:min] && value
      original = record.send(attribute.to_s.sub("_dpi", "")).queued_for_write[:original]
      if original
        image = HeritageImage.new original.path

        # We want to accept low dpi image with hight dimensions
        # Page dimension: 6x9" in 72dpi => 432x648px
        dpi = image.vdpi(432, 648)

        if dpi < options[:min]
          record.errors[attribute] << (options[:min_message] || "has too small resolution to be printed correctly")
          record.errors[attribute.to_s.sub("_dpi", "")] << (options[:min_message] || "has too small resolution to be printed correctly")
        else

          # Warning if DPI is under a certain level
          if defined?(record.warnings) && options[:warning]
            if dpi < options[:warning]
              record.warnings[attribute] << (options[:warning_message] || "has a small resolution")
            end
          end
        end
      end
    end
  end
end