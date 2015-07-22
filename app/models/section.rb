class Section < ActiveRecord::Base
  attr_accessible :cookbook_id, :name, :position, :section_image_id,
  :image_source, :photo, :lib_image, :delete_photo

  # >> Constants --------------------------------------------------------

  MAX_SECTIONS = 12

  # >> Relationships --------------------------------------------------------

  belongs_to  :cookbook
  has_many  :recipes, 
            :order => 'pages DESC, name, id',
            :dependent => :destroy
  
  has_many  :extra_pages,
            :order => 'name',
            :dependent => :destroy
  
  # >> Extensions -----------------------------------------------------------

  has_attached_file :photo, 
                    :styles => {
                      :original          => PdfImage.final_image_max_size,
                      :thumb             => "350x350>",
                      :thumb_grayscale   => "350x350>",
                      :preview           => [PdfImage.preview_image_max_size, :jpg],
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

  validates_presence_of :name, :message => 'You cannot leave section name blank.'

  validates_attachment_content_type :photo, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :photo, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Plase upload a photo smaller than 10MB'

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

  attr_accessor :delete_photo, :lib_image
  
  # >> Callbacks ------------------------------------------------------------

  after_save :update_cookbook
  after_destroy :update_cookbook

  # >> Instance Methods -----------------------------------------------------

  def to_s
    name
  end
  
  def update_cookbook
    cookbook.update_attribute(:updated_on, Time.now)
  end
  
  # Stores an image if if comes from the Image Library
  def image_source=(source)
    if self.lib_image && source == 'lib'
      self.photo = File.open(LibImage.find(self.lib_image).lib_image.path, "rb")
    end
  end
  
  def delete_photo=(param)
    self.photo = nil if param == '1'
  end
  
  def has_children?
    !self.recipes.empty? || !self.extra_pages.empty?
  end
  
  # Returns the full path for the image to be used on the pdf document
  # def pdf_image(image_version = 'preview')
  #   if image_version == 'preview'
  #     image_version += '_grayscale' if self.cookbook.grayscale?
  #     if photo_file_name_changed?
  #       photo.to_file.path
  #     elsif photo?
  #       extension = File.extname(self.photo.original_filename)
  #       "#{photo.url(image_version).gsub(/#{extension}$/, '.jpg')}"
  #     end
  #   else
  #     # extension = File.extname(self.photo.url)
  #     # basename = File.basename(self.photo.url).gsub(/#{extension}$/, '.jpg')
  #     # "#{PDF_IMAGES_PATH}#{self.cookbook.id}/sections/#{self.id}/#{basename}"
  #     self.photo.url
  #   end
  # end

  # Returns the full path for the image to be used on the pdf document
  def pdf_image(pdf_version = 'preview')
    path = false
    image_version = (pdf_version.to_s == 'final') ? 'original' : 'preview'

    if photo?
      case image_version
      when 'preview'
        image_version += '_grayscale' if self.cookbook.grayscale?

        # If the image is not uploaded yet, return the temporary path
        if self.photo.dirty?
          path = self.photo.queued_for_write[:original].path
        else
          path = self.photo.url(image_version)
        end
      when 'original'
        # Old image database do not have grayscale image, generate it if needed
        if self.cookbook.grayscale?
          path = Cookbook.generate_grayscale_image self.photo.url(image_version)
        else
          path = self.photo.url(image_version)
        end
      end
    end

    return path
  end
  
  # Todo: Maybe store the image geometry on the database so we don't have to query ImageMagick all the time
  def small_photo?
    if photo? 
      geomery = Paperclip::Geometry.from_file(photo.url)
      return geomery.width < 300 || geomery.height < 300
    end
  rescue Paperclip::NotIdentifiedByImageMagickError
    false
  end
  
end
