class Template < ActiveRecord::Base

  include TemplateConfigurationLoader

  # >> Constants -----------------------------------------------------------

  TEMPLATE_IMAGES_FOLDER = Rails.root.join("app", "book_templates")
  PDF_IMAGE_EXTENTION = '.jpg'

  # >> Relationships --------------------------------------------------------

  has_many  :cookbooks

  # >> Attributes -----------------------------------------------------------

  attr_accessor   :image_url
  attr_accessor   :image_version
  attr_accessible :book_color, :book_font, :cover_text_padding_right, :cover_title_font_size, :cover_title_font_style, 
    :cover_title_y, :cover_user_image_max_height, :cover_user_image_max_width, :cover_user_image_y, :description, :has_image, 
    :headers_font_size, :headers_font_style, :id, :inner_cover_font_size, :inner_cover_title_y, :max_tag_line_1_length,
    :max_tag_line_4_length, :name, :section_header_y, :section_user_image_max_height, :section_user_image_max_width, 
    :section_user_image_y, :show_book_title_on_inner_cover, :tag_lines, :template_type, :toc_header_y, :max_tag_line_2_length, 
    :max_tag_line_3_length, :header_color, :inner_cover_color, :cover_color, :position
  
  # >> Instance Methods -----------------------------------------------------------
  
  def thumbnail_image(type=nil)
    if type
      return '/images/templates/' + self.template_type.to_s + "/thumb-#{type}.gif"
    else
      return '/images/templates/' + self.template_type.to_s + '/thumb.gif'
    end
  end

  def cover_image
    image_exist? TEMPLATE_IMAGES_FOLDER.join(self.template_type.to_s, version_folder, "cover#{PDF_IMAGE_EXTENTION}").to_s
  end

  def inner_cover_image(grayscale=false)
    image_exist? TEMPLATE_IMAGES_FOLDER.join(self.template_type.to_s, version_folder, "#{'gray_' if grayscale}inner_cover#{PDF_IMAGE_EXTENTION}").to_s
  end
  
  def toc_image(grayscale=false)
    image_exist? TEMPLATE_IMAGES_FOLDER.join(self.template_type.to_s, version_folder, "#{'gray_' if grayscale}toc#{PDF_IMAGE_EXTENTION}").to_s
  end

  def divider_image(grayscale=false)
    image_exist? TEMPLATE_IMAGES_FOLDER.join(self.template_type.to_s, version_folder, "#{'gray_' if grayscale}divider#{PDF_IMAGE_EXTENTION}").to_s
  end

  def back_cover_image
    image_exist? TEMPLATE_IMAGES_FOLDER.join('general', version_folder, "back_cover#{PDF_IMAGE_EXTENTION}").to_s
  end

  def version_folder
    image_version == 'original' ? 'final' : 'preview'
  end

  # Return path if the image exist, false if not. 
  # Path can be an url.
  def image_exist?(path)
    begin
      open path
      return path
    rescue
      # File at disk or url does not exist
      return false
    end
  end
end
