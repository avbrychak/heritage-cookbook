require "open-uri"

class Object

  # Process parameters for two actions:
  # * Delete paperclip attachments
  # * Use an image from the Image Library instead of an uploaded file
  # This method do not save the object.
  #    f.paperclip_attachment :user_image, image_library: true
  def process_attachments(params)

    # Insert image library
    if params[:libimage]
      params[:libimage].each do |key, value|
        
        if value != ""

          # If path is relative, give the complete path
          value = "#{Rails.root.join("public").to_s}#{value}" if !(value =~ /(https?:\/\/)/)

          attachment = open(value)
          self.send("#{key}=", attachment) if File.exist?(attachment)
        end
      end
    end

    # Remove images if needed
    if params[:remove]
      params[:remove].each_key do |key|
        self.send("#{key}=", nil)
      end
    end
  end
end

module ActionView::Helpers::FormHelper

  # Display an image form supporting paperclip attachment upload 
  # and deletion and optionnal support for the image library.
  # Render the `image_upload` partial view.
  def paperclip_attachment(object_name, method, options={})
    @image_library = options[:image_library]
    @options = options
    @object = options[:object]
    @object_name = object_name
    @method = method
    render "layouts/image_upload"
  end
end

class ActionView::Helpers::FormBuilder

  # Register a FormBuilder helper for paperclip attachment.
  def paperclip_attachment(method, options={})
    @multipart = true
    @template.paperclip_attachment(@object_name, method, objectify_options(options))
  end
end