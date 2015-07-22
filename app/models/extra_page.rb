class ExtraPage < ActiveRecord::Base

  attr_accessible :section_id, :user_id, :name, :grayscale, :text, :pages, :index_as_recipe, :image_source, 
    :lib_image, :user, :photo, :delete_photo, :section

  # >> Relationships --------------------------------------------------------

  belongs_to  :section
  belongs_to  :user

  # >> Extensions -----------------------------------------------------------

  has_attached_file :photo, 
                    :styles => {
                      :original          => PdfImage.final_image_max_size,
                      :thumb            => "350x350>",
                      :thumb_grayscale  => "350x350>",
                      :preview          => [PdfImage.preview_image_max_size, :jpg],
                      :preview_grayscale => [PdfImage.preview_image_max_size, :jpg]
                    },
                    :convert_options => {
                      :all                => "-strip", 
                      :thumb_grayscale    => '-colorspace Gray',
                      :preview_grayscale  => '-colorspace Gray'
                    },
                    :storage => :s3,
                    :s3_credentials => Rails.root.join('config', 's3.yml'),
                    :path => ":class/:attachment/:id/:style/:basename.:extension"


  # >> Validations ----------------------------------------------------------

  validates_attachment_content_type :photo, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :photo, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Plase upload a photo smaller than 10MB'
  
  validates_presence_of  :name, :message => "Please give your extra page a name."

  # Validate image DPI before Paperclip start its convertion
  validates :photo_dpi, dpi: {
    min: 70, 
    min_message: "The resolution of your photo is too low and might be blurry when printed. Reload it at a higher resolution.",
    warning: 150,
    warning_message: "The resolution of your photo is a little low and might be blurry when printed.\nIf you can, reload it at a higher resolution, or put a note when you place your order to have this photo checked before it's printed"
  }

  # Before converting the images with paperclip:
  # * Ensure the image do not excess 300DPI
  # * Write the image resolution and dimension
  include PaperclipImageExtensions
  before_photo_post_process do
    convert_dpi(:photo)
    image_dimensions(:photo)
  end

  # >> Attributes -----------------------------------------------------------

  attr_accessor   :delete_photo, 
                  :lib_image, 
                  :image_source,
                  :tmp_filename
                  
  # >> Callbacks ------------------------------------------------------------------

  before_save       :save_photo_dimensions, :strip_name
  before_save       :save_page_length
  after_save        :remove_tmp_file, :update_cookbook
  after_destroy     :update_cookbook

  # >> Instance Methods -----------------------------------------------------------

  def update_cookbook
    section.cookbook.update_attribute(:updated_on, Time.now)
  end

  def save_photo_dimensions
    if photo? && photo_file_name_changed?
      geometry = Paperclip::Geometry.from_file(photo.queued_for_write[:original].path)
      self.photo_width = geometry.width
      self.photo_height = geometry.height
    end
  end

  def save_page_length
    self.pages = CookbookGenerator.get_extra_page_length(self)[:page]
  end
  
  def remove_tmp_file
    FileUtils.rm(self.tmp_filename) if self.tmp_filename
  end
  
  # Returns true if this extra_page belongs to the specified cookbook
  def belongs_to_cookbook(cookbook_id)
    self.section.cookbook.id == cookbook_id
  end

  # Returns true if user is the author
  def author_is(user)
    self.user_id == user.id
  end                                                                                                                     

  # Can a person edit this recipe?
  def editable_by?(user, cookbook)
    self.author_is(user) || (user.owns_cookbook(cookbook) && self.belongs_to_cookbook(cookbook.id))
  end                                                                                                           

  # Can a person delete this recipe?
  def deletable_by?(user, cookbook)
    editable_by?(user, cookbook)
  end

  # Returns the full path for the photo to be used on the pdf document
  # def pdf_photo(image_version = 'preview')
  #   if image_version == 'preview'
  #     image_version += '_grayscale' if self.grayscale?
  #     if photo_file_name_changed? && photo?
  #       extension = File.extname(self.photo.original_filename)
  #       basename = File.basename(self.photo.original_filename).gsub(/#{extension}$/, '.jpg')
  #       self.tmp_filename = "/tmp/_hc_tmp_#{Time.now.to_i}_#{basename}"
  #       PdfImage.convert(:resize, photo.queued_for_write[:original].path, self.tmp_filename)
  #       self.tmp_filename
  #     elsif photo?
  #       extension = File.extname(self.photo.original_filename)
  #       "#{photo.url(image_version).gsub(/#{extension}$/, '.jpg')}"
  #     end
  #   else
  #     # extension = File.extname(self.photo.url)
  #     # basename = File.basename(self.photo.url).gsub(/#{extension}$/, '.jpg')
  #     # "#{PDF_IMAGES_PATH}#{self.section.cookbook.id}/extra_pages/#{self.id}/#{basename}"
  #     self.photo.url
  #   end
  # end

  # Returns the full path for the photo to be used on the pdf document
  # PDF version can be preview or final
  # Image version can be preview or original
  def pdf_photo(pdf_version = 'preview')
    path = false
    image_version = (pdf_version == :final) ? 'original' : 'preview'

    if photo?
      case image_version
      when 'preview'
        image_version += '_grayscale' if self.grayscale?

        # If the image is not uploaded yet, return the temporary path
        if self.photo.dirty?
          path = self.photo.queued_for_write[:original].path
        else
          path = self.photo.url(image_version)
        end
      when 'original'
        # Old image database do not have grayscale image, generate it if needed
        if self.grayscale?
          path = Cookbook.generate_grayscale_image self.photo.url(image_version)
        else
          path = self.photo.url(image_version)
        end
      end
    end

    return path
  end  

  # Stores an image if it comes from the Image Library
  def image_source=(source)
    if self.lib_image && source == 'lib'
      self.photo = File.open(LibImage.find(self.lib_image).lib_image.path, "rb")
    end
  end
  
  def delete_photo=(param)
    self.photo = nil if param == '1'
  end

  # Todo: Maybe store the image geometry on the database so we don't have to query ImageMagick all the time
  def small_photo?
    if photo? && photo_width && photo_height
      return (photo_width < 300 || photo_height < 300)
    else
      return false
    end
  end

  def strip_name
    self.name = self.name.strip
  end
  
end
