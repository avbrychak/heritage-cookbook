class LibImage < ActiveRecord::Base

  attr_accessible :lib_image
  
  # >> Extensions -----------------------------------------------------------

  has_attached_file :lib_image, 
                    :styles => {
                      :original => PdfImage.final_image_max_size,
                      :thumb    => "100x100",
                      :preview  => PdfImage.preview_image_max_size
                    },
                    :storage => :s3,
                    :s3_credentials => Rails.root.join('config', 's3_image_library.yml')
        
  # acts_as_taggable
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  # >> Validations ----------------------------------------------------------

  validates_attachment_presence :lib_image, 
    :message      => 'Please select a photo to upload'
  validates_attachment_content_type :lib_image, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :lib_image, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Plase upload a photo smaller than 10MB'

  validates :tags, presence: {message: "An image need at least one tag"}
  
  # >> Attributes -----------------------------------------------------------

  attr_accessor  :image_tags

  # Find images tagged with a list of tags.
  # Imported from an old `act_as_taggable` plugin.
  def self.find_tagged_with(list)
    find_by_sql([
      "SELECT #{table_name}.* FROM #{table_name}, tags, taggings " +
      "WHERE #{table_name}.#{primary_key} = taggings.taggable_id " +
      "AND taggings.taggable_type = ? " +
      "AND taggings.tag_id = tags.id AND tags.name IN (?)",
      "LibImage", list
    ])
  end

  # Tag an image with a list of tags.
  def tag_with(tag_names)
    _tags = []
    Tag.parse(tag_names).each do |tag_name|
      _tags << Tag.find_or_create_by_name(tag_name.downcase)
    end
    self.tags = _tags.uniq
  end

  # Return a list of tags separated by spaces.
  # Imported from an old `act_as_taggable` plugin.
  def tag_list
    tags.map { |tag| tag.name.include?(" ") ? '"' +"#{tag.name}" + '"' : tag.name }.join(" ")
  end
  
end
