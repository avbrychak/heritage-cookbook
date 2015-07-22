class Recipe < ActiveRecord::Base  
  attr_accessible :section_id, :name, :servings, :ingredient_list, :instructions, :story, 
    :photo_file_name, :submitted_by, :grayscale, :pages, :shared, :position, :photo_archive, 
    :force_own_page, :submitted_by_title, :ingredients_uses_two_columns, :ingredient_list_2, 
    :image_source, :photo, :lib_image, :user, :delete_photo, :section, :single_page

  # >> Constants -----------------------------------------------------------

  SUBMITTED_BY_OPTIONS = [
    ['Submitted By:'],
    ['Written By:'],
    ['Contributed By:'],
    ['(leave blank)', '']
  ]

  # >> Relationships --------------------------------------------------------

  belongs_to  :section
  belongs_to  :user, :counter_cache => true
  
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

  validates_presence_of :name, :message => "Please give your recipe a name."

  validates_attachment_content_type :photo, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :photo, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Please upload a photo smaller than 10MB'

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
    
  attr_accessor :delete_photo, :lib_image, :ignore_low_res_warning, :tmp_filename
  
  # >> Callbacks ------------------------------------------------------------
  
  # before_save :save_photo_dimensions
  # before_save :get_length
  after_validation :get_length
  after_save :update_cookbook
  after_destroy :update_cookbook
  
  # >> Instance Methods -----------------------------------------------------------
  
  def update_cookbook
    section.cookbook.update_attribute(:updated_on, Time.now)
  end

  # Todo: Maybe store the image geometry on the database so we don't have to query ImageMagick all the time
  def small_photo?
    if photo? && photo_width && photo_height
      return (photo_width < 300 || photo_height < 300)
    else
      return false
    end
  end
  
  def delete_photo=(param)
    self.photo = nil if param == '1'
  end
  
  def save_photo_dimensions    
    if photo? && photo_file_name_changed?      
      # geometry = Paperclip::Geometry.from_file(photo.path)
      geometry = Paperclip::Geometry.from_file photo.queued_for_write[:original].path
      self.photo_width = geometry.width
      self.photo_height = geometry.height
    end
  #rescue Paperclip::NotIdentifiedByImageMagickError
  end
  
  # Returns true if this recipe belongs to the specified cookbook
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
  #       if File.exist? self.tmp_filename
  #         return self.tmp_filename
  #       else
  #         return false
  #       end
      

  #     elsif photo?
  #       extension = File.extname(self.photo.original_filename)
  #       "#{photo.url(image_version).gsub(/#{extension}$/, '.jpg')}"
  #     end
  #   else
  #     # extension = File.extname(self.photo.url)
  #     # basename = File.basename(self.photo.url).gsub(/#{extension}$/, '.jpg')
  #     # "#{PDF_IMAGES_PATH}#{self.section.cookbook.id}/recipes/#{self.id}/#{basename}"
  #     self.photo.url
  #   end
  # end

  # Returns the full path for the photo to be used on the pdf document
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

  # Stores an image if if comes from the Image Library
  def image_source=(source)
    if self.lib_image && source == 'lib'
      self.photo = File.open(LibImage.find(self.lib_image).lib_image.path, "rb")
    end
  end
  
  # Return the page lenght and write errors with an estimation of the extra line space
  # Can be 0.5 or 1 if no photo or single page layout, 2 if photo
  def get_length
    
    # Do not try to generate a PDF if the recipe has some errors (like bad images)
    return false if errors.any?
    
    recipe_length = CookbookGenerator.get_recipe_length(self) # [pages, y] with y from Prawn (bottom left of the page)
    story_length  = CookbookGenerator.get_story_length(self)  # [pages, y] with y from Prawn (bottom left of the page)
    page_height   = CookbookGenerator::HC_PAGE_HEIGHT # pt

    # Get page lenght.
    # If the recipe have a photo, it will take 1 or 2 pages (story on the left, recipe on the right).
    if photo?
      self.pages = recipe_length[:page]
    else
      if recipe_length[:y] >= ((page_height / 2) + CookbookGenerator::HC_GAP) && recipe_length[:page] == 1
        self.pages = 0.5
      else
        self.pages = recipe_length[:page]
      end
    end


    # The active area is the area where content can be writted
    active_area = CookbookGenerator::HC_PAGE_HEIGHT - CookbookGenerator::HC_PAGE_MARGIN[:bottom] - CookbookGenerator::HC_PAGE_MARGIN[:bottom]

    # Calculate the position relative to the bottom of the `active_area` and not to the bottom of the page
    position = recipe_length[:y] - CookbookGenerator::HC_PAGE_MARGIN[:bottom]

    # Set errors on page lenght
    if !photo? || single_page

      # Should be 1 page max (story + ingredients + instructions + photo)
      if recipe_length[:page] > 1

        lines = extra_lines(position, recipe_length[:page], active_area, 1)

        if story.empty?
          %w(ingredient_list instructions single_page).each do |field|
            errors.add(field, "Your ingredients list and preparation instructions are too long by ~#{lines} lines.")
          end

        else
          %w(ingredient_list instructions story single_page).each do |field|
            errors.add(field, "Your ingredients list and preparation instructions plus your story are too long by ~#{lines} lines.")
          end
        end
      end
    else

      # Should be 2 pages max (1 story + photo, 1 ingredients + instructions)
      if recipe_length[:page] > 2

        # If the story is too long
        if story_length[:page] > 1

          story_position = story_length[:y] - CookbookGenerator::HC_PAGE_MARGIN[:bottom]
          lines = extra_lines(story_position, story_length[:page], active_area, 1)

          errors.add(:story, "Your story is too long by ~#{lines} lines.")

        # If the recipe is too long
        else

          lines = extra_lines(position, recipe_length[:page], active_area, 2)

          %w(ingredient_list instructions).each do |field|
            errors.add(field, "Your ingredients list plus your preparation instructions are too long by ~#{lines} lines.")
          end
        end
      end
    end
    
    return errors.empty?
  end

  private

  # Approximate the number of extra lines to keep the content in the given `max_number_of_pages`
  # * `position` is the vertical position of the bottom of the page content on the last page, 
  #   relative to the `page_height` with the origin at the bottom of the `page_height`
  # * `num_pages` is the total number of pages the content takes
  # * `page_height` represent the height of the writable area in the page
  # * `max number of page` represent the number of page allowed for the content
  def extra_lines(position, num_pages, page_height, max_number_of_pages)
    line_height = CookbookGenerator::TEXT_FONT_SIZE + CookbookGenerator::HC_LINE_HEIGHT

    # Count extra lines on the last page
    extra_lines_counter = (page_height - position) / line_height

    # Count extra lines on each extra pages
    extra_lines_counter += ((num_pages - max_number_of_pages - 1) * page_height) / line_height

    return (extra_lines_counter.to_i == 0) ? 1 : extra_lines_counter.to_i
  end

  # Return an approximative number of extra line
  # def extra_lines(length, page_height, max_number_of_pages)
  #   line_height = CookbookGenerator::TEXT_FONT_SIZE + CookbookGenerator::HC_LINE_HEIGHT
  #   lines = ((page_height - length[:y]) / line_height) + (((length[:page] - max_number_of_pages - 1) * page_height) / line_height)
  #   return (lines.to_i == 0) ? 1 : lines.to_i
  # end

  # def get_length_old
  #   # Cloning the recipe so it doesn't get changed
  #   recipe = self.clone
  #   recipe.id = self.id
  #   recipe.photo = self.photo? ? File.new(self.photo.to_file.path) : nil
    
  #   recipe.pages = 0 # Reset the page count so we can get the real length
  #   recipe_length = PdfCookbook.get_recipe_length(recipe)
  #   story_length = PdfCookbook.get_story_length(recipe)
  #   page_height = PdfCookbook::HC_PAGE_HEIGHT-PdfCookbook::HC_EVEN_MARGIN[:bottom]

  #   if !photo?
  #     self.pages = case 
  #       when recipe_length[:y]+(page_height*(recipe_length[:page]-1)) <= (page_height/2)-5
  #         0.5
  #       else 
  #         recipe_length[:page]
  #     end
  #     # Check if we need to force the recipe to sit on its own page
  #     if self.pages==0.5 && force_own_page==1
  #       self.pages=1
  #     end
  #   else
  #     self.pages = recipe_length[:page]
  #   end

  #   if !photo?
  #     if self.story.blank?
  #       if recipe_length[:page] > 1
  #         extra_pages = recipe_length[:page] - 2
  #         recipe_extra_lines = ((recipe_length[:y] - PdfCookbook::HC_EVEN_MARGIN[:top])/PdfCookbook::HC_LINE_HEIGHT) + (extra_pages * 41)
  #         %w(ingredient_list instructions).each do |field|
  #           errors.add(field, "Your ingredients list plus your preparation instructions are #{recipe_extra_lines.ceil} lines too long.")
  #         end
  #       end

  #     else
  #       if recipe_length[:page] > 1
          
  #         # Check if the story is too long
  #         validate_story_length(story_length)

  #         # Check if the recipe is too long
  #         extra_pages = recipe_length[:page] - 2
  #         recipe_extra_lines = ((recipe_length[:y] - story_length[:y] + (3*PdfCookbook::HC_LINE_HEIGHT) - PdfCookbook::HC_EVEN_MARGIN[:top])/PdfCookbook::HC_LINE_HEIGHT) + (extra_pages * 41)
  #         if recipe_extra_lines > 0
  #           %w(ingredient_list instructions).each do |field|
  #             errors.add(field, "Your ingredients list plus your preparation instructions are #{recipe_extra_lines.ceil} lines too long.")
  #           end
  #         end
  #       end
  #     end
    
  #   # We have a photo
  #   else
  #     if recipe_length[:page] > 2
        
  #       # Check if the story is too long
  #       validate_story_length(story_length)
        
  #       # Check if the recipe is too long
  #       extra_pages = recipe_length[:page] - 3
  #       recipe_extra_lines = ((recipe_length[:y] - PdfCookbook::HC_EVEN_MARGIN[:top])/PdfCookbook::HC_LINE_HEIGHT) + (extra_pages * 41)
  #       if recipe_extra_lines > 0
  #         %w(ingredient_list instructions).each do |field|
  #           errors.add(field, "Your ingredients list plus your preparation instructions are #{recipe_extra_lines.ceil} lines too long.")
  #         end
  #       end
  #     end
  #   end
  #   return errors.empty?
  # end

  # def validate_story_length(story_length)
  #   extra_pages = story_length[:page] - 2
  #   story_extra_lines = ((story_length[:y] - PdfCookbook::HC_EVEN_MARGIN[:top])/PdfCookbook::HC_LINE_HEIGHT) + (extra_pages * 41)
  #   if story_extra_lines > 0
  #     errors.add("story", "Your story is #{story_extra_lines.ceil} lines too long.")
  #   end
    
  # end
end
