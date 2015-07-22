class Cookbook < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  attr_accessible :intro_type, :intro_text, :template_id, :title, :tag_line_1, :tag_line_2, 
    :tag_line_3, :tag_line_4, :grayscale, :center_introduction, :expired, :show_index, 
    :is_locked_for_printing, :notes, :user_image, :user_lib_image, :user_cover_lib_image, 
    :user_inner_cover_lib_image, :user_cover_image_source, :user_inner_cover_image_source, 
    :intro_image_source, :intro_image, :intro_image_grayscale, :intro_lib_image, :delete_intro_image,
    :user_image_source, :delete_user_image, :user_cover_image, :user_inner_cover_image,
    :delete_user_cover_image, :delete_user_inner_cover_image, :inner_cover_image_grayscale, :book_binding_id
  
  # These will be added to every new cookbook
  DEFAULT_COOKBOOK_SECTIONS = [ 
      'Appetizers',
      'Soups',
      'Salads',
      'Beverages',
      'Vegetables',
      'Side Dishes',
      'Meat and Game',
      'Fish and Seafood',
      'Poultry',
      'Baked Goods',
      'Desserts',
      'Other'
   ]
   
 # >> Relationships --------------------------------------------------------

  has_many  :authorships, 
            :dependent => :destroy
  has_many  :users,
            :through => :authorships,
            :source => :user
  has_many   :owners, 
            :through => :authorships,
            :source => :user, 
            :conditions => ['authorships.role = 1']
  has_many   :contributors, 
            :through => :authorships, 
            :source => :user,
            :conditions => ['authorships.role = 2'],
            :order => 'users.first_name, users.last_name'
  belongs_to  :template
  has_many    :sections,
            :order => "sections.position, sections.name, recipes.pages DESC, recipes.name, extra_pages.name",
            :include => ["recipes", 'extra_pages'],
            :dependent => :destroy
  has_many  :recipes,
            :through => :sections
  has_many  :extra_pages,
            :through => :sections
  has_many  :orders, 
            :dependent => :destroy
  has_many  :paid_orders,
            :class_name => 'Order',
            :conditions => ['paid_on is not null']
  # has_one   :unpaid_order,
  #           :class_name => 'Order',
  #           :conditions => ['paid_on is null']
  belongs_to :book_binding

  # >> Extensions -----------------------------------------------------------

  has_attached_file :user_image, 
                    :styles => {
                      :original          => PdfImage.final_image_max_size,
                      :thumb            => "350x350>",
                      :preview          => [PdfImage.preview_image_max_size, :jpg]
                    },
                    :convert_options => {:all => "-strip"},
                    :storage => :s3,
                    :s3_credentials => Rails.root.join('config', 's3.yml'),
                    :path => ":class/:attachment/:id/:style/:basename.:extension"

  has_attached_file :user_cover_image, 
                    :styles => {
                      :original          => PdfImage.final_image_max_size,
                      :thumb            => "350x350>",
                      :preview          => [PdfImage.preview_image_max_size, :jpg]
                    },
                    :convert_options => {:all => "-strip"},
                    :storage => :s3,
                    :s3_credentials => Rails.root.join('config', 's3.yml'),
                    :path => ":class/:attachment/:id/:style/:basename.:extension"
                    
  has_attached_file :user_inner_cover_image, 
                    :styles => {
                      :original          => PdfImage.final_image_max_size,
                      :thumb            => "350x350>",
                      :thumb_grayscale  => "350x350>",
                      :preview          => [PdfImage.preview_image_max_size, :jpg],
                      :preview_grayscale => [PdfImage.preview_image_max_size, :jpg]
                    },
                    :convert_options => { 
                      :all => "-strip", 
                      :thumb_grayscale => '-colorspace Gray',
                      :preview_grayscale  => '-colorspace Gray'},
                    :storage => :s3,
                    :s3_credentials => Rails.root.join('config', 's3.yml'),
                    :path => ":class/:attachment/:id/:style/:basename.:extension"

  has_attached_file :intro_image, 
                    :styles => {
                      :original          => PdfImage.final_image_max_size,
                      :thumb            => "350x350>",
                      :thumb_grayscale  => "350x350>",
                      :preview          => [PdfImage.preview_image_max_size, :jpg],
                      :preview_grayscale => [PdfImage.preview_image_max_size, :jpg]
                    },
                    :convert_options => {
                      :all => "-strip", 
                      :thumb_grayscale => '-colorspace Gray',
                      :preview_grayscale  => '-colorspace Gray'
                      },
                      :storage => :s3,
                      :s3_credentials => Rails.root.join('config', 's3.yml'),
                      :path => ":class/:attachment/:id/:style/:basename.:extension"

  # >> Validations ----------------------------------------------------------

  validates_presence_of :title, :message => 'Your cookbook title can\'t be blank.'
  validates_length_of :title, :maximum => 30, :message => 'Your cookbook title is too long.'
  validates_length_of :tag_line_1, :maximum => 50, :message => "Your tagline #1 title is too long."
  validates_length_of :tag_line_2, :maximum => 50, :message => "Your tagline #2 title is too long."
  validates_length_of :tag_line_3, :maximum => 50, :message => "Your tagline #3 title is too long."
  validates_length_of :tag_line_4, :maximum => 50, :message => "Your tagline #4 title is too long."

  validates_attachment_content_type :user_image, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :user_image, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Plase upload a photo smaller than 10MB'

  # Validate image DPI before Paperclip start its convertion
  validates :user_image_dpi, dpi: {
    min: 70, 
    min_message: "The resolution of your photo is too low and might be blurry when printed. Reload it at a higher resolution.",
    warning: 150,
    warning_message: "The resolution of your photo is a little low and might be blurry when printed.\nIf you can, reload it at a higher resolution, or put a note when you place your order to have this photo checked before it's printed"
  }

  validates_attachment_content_type :user_cover_image, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :user_cover_image, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Plase upload a photo smaller than 10MB'

  # Validate image DPI before Paperclip start its convertion
  validates :user_cover_image_dpi, dpi: {
    min: 70, 
    min_message: "The resolution of your photo is too low and might be blurry when printed. Reload it at a higher resolution.",
    warning: 150,
    warning_message: "The resolution of your photo is a little low and might be blurry when printed.\nIf you can, reload it at a higher resolution, or put a note when you place your order to have this photo checked before it's printed"
  }

  validates_attachment_content_type :user_inner_cover_image, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :user_inner_cover_image, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Plase upload a photo smaller than 10MB'

  # Validate image DPI before Paperclip start its convertion
  validates :user_inner_cover_image_dpi, dpi: {
    min: 70, 
    min_message: "The resolution of your photo is too low and might be blurry when printed. Reload it at a higher resolution.",
    warning: 150,
    warning_message: "The resolution of your photo is a little low and might be blurry when printed.\nIf you can, reload it at a higher resolution, or put a note when you place your order to have this photo checked before it's printed"
  }

  validates_attachment_content_type :intro_image, 
    :content_type => %w{image/jpeg image/pjpeg image/gif image/png},
    :message      => 'Please only upload photos of type .jpg, .gif or .png'
  validates_attachment_size :intro_image, 
    :less_than    => 10.megabytes, 
    :message      => 'Your file is too big. Plase upload a photo smaller than 10MB'
  
  # Validate image DPI before Paperclip start its convertion
  validates :intro_image_dpi, dpi: {
    min: 70, 
    min_message: "The resolution of your photo is too low and might be blurry when printed. Reload it at a higher resolution.",
    warning: 150,
    warning_message: "The resolution of your photo is a little low and might be blurry when printed.\nIf you can, reload it at a higher resolution, or put a note when you place your order to have this photo checked before it's printed"
  }

  # Before converting the images with paperclip:
  # * Ensure the image do not excess 300DPI
  # * Write the image resolution and dimension
  include PaperclipImageExtensions
  before_intro_image_post_process do
    convert_dpi(:intro_image)
    image_dimensions(:intro_image)
  end
  before_user_image_post_process do
    convert_dpi(:user_image)
    image_dimensions(:user_image)
  end
  before_user_cover_image_post_process do
    convert_dpi(:user_cover_image)
    image_dimensions(:user_cover_image)
  end
  before_user_inner_cover_image_post_process do
    convert_dpi(:user_inner_cover_image)
    image_dimensions(:user_inner_cover_image)
  end


  # >> Attributes -----------------------------------------------------------

  attr_accessor   :user_lib_image, :user_image_source, :delete_user_image, 
                  :user_cover_lib_image, :user_cover_image_source, :delete_user_cover_image, 
                  :user_inner_cover_lib_image, :user_inner_cover_image_source, :delete_user_inner_cover_image, 
                  :intro_lib_image, :intro_image_source, :delete_intro_image
  
  before_save :save_lib_images, :check_grayscale_settings, :save_updated_on #, :check_intro_length
  
  after_create :create_cookbook_default_sections

  # >> Instance Methods --------------------------------------------------------

  # Render the preview PDF file
  def render_preview(path=nil)
    filename = path || "/tmp/preview_#{id}_#{Time.now.to_i}.pdf"

    # book = PdfCookbook.new
    book = CookbookGenerator.new(
      version: :preview,
      cookbook: self,
      layout: :book
    )
    book.render_cookbook
    book.document.to_file filename
  end

  # Render the final PDF file
  def render_final(path=nil)
    filename = path || "/tmp/cookbook_#{order_id}_#{id}-#{Time.now.strftime("%H_%M_%d_%m_%Y")}.pdf"

    # book = PdfCookbook.new(true)
    book = CookbookGenerator.new(
      version: :final,
      cookbook: self,
      layout: :book
    )
    book.render_cookbook
    book.document.to_file filename
  end

  def save_updated_on
    updated_on = Time.now unless is_locked_for_printing_changed?
  end

  def check_grayscale_settings
    if self.grayscale?
      self.inner_cover_image_grayscale = true
    end
  end
  
  def save_lib_images
    %w{user user_cover user_inner_cover intro}.each  do |attachment_name|
      if self.send("#{attachment_name}_image_source") == 'lib' && !self.send("#{attachment_name}_lib_image").blank?
        library_image = LibImage.find(self.send("#{attachment_name}_lib_image"))
        self.send("#{attachment_name}_image=", File.open(library_image.lib_image.path, "rb"))
      end
    end
  end
  
  %w{user user_cover user_inner_cover intro}.each  do |attachment_name|
    # Deletes an image
    define_method "delete_#{attachment_name}_image=".to_sym do |param|
      self.send("#{attachment_name}_image=", nil) if param == '1'
    end
  end
  
  # Make sure that the introduction is no longer than 1 page long
  # Diabled until futher specs.
  def check_intro_length
    if self.template 
        position = PdfCookbook.get_introduction_length(self)
        if position[:page] > 1
          lines = ((position[:y] - PdfCookbook::HC_EVEN_MARGIN[:top])/PdfCookbook::HC_LINE_HEIGHT)
          errors.add("intro_text", "Your #{introduction_name} is using #{position[:page]} pages, it's approximately #{lines.round.to_s} lines too long.")
          return false
        end
    end
  end

  def create_cookbook_default_sections
    # Add the default list of sections to the new cookbook
    DEFAULT_COOKBOOK_SECTIONS.each_with_index do |section, i| 
      self.sections.create(:name => section, :position => i+1) 
    end
  end

  # Replace:
  # has_one   :unpaid_order,
  #           :class_name => 'Order',
  #           :conditions => ['paid_on is null']  
  def unpaid_order(user_id = self.owner.id)
    result = orders.where("paid_on IS NULL AND user_id = ? AND reorder_id IS NULL", user_id)
    return (result.any?) ? result.first : false
  end

  def get_active_order(user = nil)
    order_user = (user) ? user : self.owner
    order = unpaid_order(order_user.id)
    if order
      return order
    else
      order = Order.new(:cookbook_id => self.id, :number_of_books => 4)
      
      # populating order with user data (default)
      order.user = order_user
      order.bill_first_name = order.ship_first_name = order_user.first_name
      order.bill_last_name = order.ship_last_name = order_user.last_name
      order.bill_address = order.ship_address = order_user.address unless order_user.address == nil
      order.bill_address2 = order.ship_address2 = order_user.address2 unless order_user.address2 == nil
      order.bill_city = order.ship_city = order_user.city unless order_user.city == nil
      order.bill_zip = order.ship_zip = order_user.zip unless order_user.zip == nil
      order.bill_country = order.ship_country = order_user.country unless order_user.country == nil
      order.bill_state = order.ship_state = order_user.state unless order_user.state == nil
      order.bill_phone = order.ship_phone = order_user.phone unless order_user.phone == nil
      order.bill_email = order.ship_email = order_user.email
      if !order.save
        return false
      else
        return order
      end
    end
  end

  # Return the last reorder for the given order
  def unpaid_reorder(old_order_id, user_id = self.owner.id)
    reorders = orders.where("paid_on IS NULL AND reorder_id = ? AND user_id = ?", old_order_id, user_id)
    return (reorders.any?) ? reorders.last : false
  end

  # Return the las reorder for the given order or create a new one
  def get_active_reorder(old_order_id, user = nil)
    order_user = (user) ? user : self.owner
    order = unpaid_reorder(old_order_id, order_user.id)
    old_order = Order.find old_order_id
    if !order
      order = orders.find(old_order_id).dup
      order.reorder_id = old_order_id
      order.paid_on = nil
      order.transaction_data = nil
      order.notes = nil
      order.delivery_time = nil
      order.created_on = Time.now

      # If the old order has no binding, assign one by default (coil)
      order.book_binding = old_order.book_binding || DEFAULT_BINDING

      # populating order with user data (default)
      order.user = order_user
      order.bill_first_name = order.ship_first_name = order_user.first_name
      order.bill_last_name = order.ship_last_name = order_user.last_name
      order.bill_address = order.ship_address = order_user.address unless order_user.address == nil
      order.bill_address2 = order.ship_address2 = order_user.address2 unless order_user.address2 == nil
      order.bill_city = order.ship_city = order_user.city unless order_user.city == nil
      order.bill_zip = order.ship_zip = order_user.zip unless order_user.zip == nil
      order.bill_country = order.ship_country = order_user.country unless order_user.country == nil
      order.bill_state = order.ship_state = order_user.state unless order_user.state == nil
      order.bill_phone = order.ship_phone = order_user.phone unless order_user.phone == nil
      order.bill_email = order.ship_email = order_user.email

      # order.save(validate: false)
      if !order.save
        return false
      end
    end

    return order
  end
  
  def is_owner? (user)
    self.owners.collect{|person| person.id}.include?(user.id)
  end
  
  def is_user? (user)
    self.users.collect{|person| person.id}.include?(user.id)
  end
  
  def is_contributor? (user)
    self.contributors.collect{|person| person.id}.include?(user.id)
  end

  def introduction_name
    intro_type == 0 ? 'introduction' : 'dedication'
  end
  
  def num_recipes
    self.recipes.size
  end
  
  def num_extra_pages
    self.extra_pages.size
  end
  
  def num_sections_with_recipes
    self.recipes.collect {|recipe| recipe.section_id}.uniq.size
  end

  def sections_with_recipes
    recipes.collect {|recipe| recipe.section_id}.uniq
  end
  
  def num_recipes_not_contributed_by(user_id)
    self.recipes.select {|recipe| recipe.user_id != user_id}.size
  end
  
  def num_recipes_contributed_by(user_id)
    self.recipes.select {|recipe| recipe.user_id == user_id}.size
  end
  
  def num_extra_pages_contributed_by(user_id)
    self.extra_pages.select {|extra_page| extra_page.user_id == user_id}.size
  end
  
  def num_pages
    @num_pages ||= CookbookGenerator.get_book_length(self)
  end

  def num_color_pages
    @num_color_pages ||= CookbookGenerator.get_book_color_pages(self)
  end

  def num_bw_pages
    num_pages - num_color_pages - 2
  end
  
  # If we ever have more than one person owning a cookbook, this will have
  # to be changed, but for now it works fine
  def owner
    self.owners[0]
  end

  # def image_path(image)
  #   path = false
  #   self.template.image_version ||= 'preview'
  #   if self.template.image_version == 'preview'
  #     image_version = self.template.image_version
  #     case image
  #       when 'user_inner_cover_image'
  #         image_version += '_grayscale' if self.grayscale? || self.inner_cover_image_grayscale?
  #       when 'intro_image'
  #         image_version += '_grayscale' if self.intro_image_grayscale?
  #     end
  #     extension = File.extname(self.send(image).url(image_version))

  #     # If the image is not uploaded yet, return the temporary path
  #     if self.send(image).dirty?
  #       path = self.send(image).queued_for_write[image_version.to_sym].path
  #     else
  #       path = self.send(image).url(image_version).gsub(/#{extension}$/, '.jpg')
  #     end
  #   else
  #     # extension = File.extname(self.send(image).url)
  #     # basename = File.basename(self.send(image).url).gsub(/#{extension}$/, '.jpg')
  #     # path = "#{PDF_IMAGES_PATH}#{self.id}/#{image.pluralize}/#{basename}"
  #     path = self.send(image).url
  #   end

  #   return path
  # end

  # Select the image to print on the cookbook (final/preview, grayscale/color)
  # Generate the grayscale image if not exist (inner cover and introduction)
  def image_path(image)
    path = false
    self.template.image_version ||= 'preview'
    image_version = self.template.image_version

    case image_version
    when 'preview'

      # Test if user specified image in grayscale
      case image
      when 'user_inner_cover_image'
        image_version += '_grayscale' if self.grayscale?
      when 'intro_image'
        image_version += '_grayscale' if self.intro_image_grayscale?
      end

      # If the image is not uploaded yet, return the temporary path
      if self.send(image).dirty?
        path = self.send(image).queued_for_write[image_version.to_sym].path
      else
        path = self.send(image).url(image_version)
      end
    when 'original'

      # Test if user specified image in grayscale
      # If specified, as the old image database do not provide greyscale version of original image, 
      # generate them.
      if image == 'user_inner_cover_image' && (self.grayscale?) && user_inner_cover_image?
        path = Cookbook.generate_grayscale_image self.send(image).url(image_version)
      elsif image == 'intro_image' && self.intro_image_grayscale? && intro_image?
        path = Cookbook.generate_grayscale_image self.send(image).url(image_version)
      else
        path = self.send(image).url(image_version)
      end
    end

    return path
  end

  # Generate the final pdf of this cookbook
  # NOT USED ANYMORE
  # def generate_final_pdf(order_id)
  #   template.image_version = 'original'
  #   pdf_path = "#{PDF_IMAGES_PATH}#{self.id}/"
    
  #   generate_pdf_images(pdf_path)
    
  #   # Create the final pdf cookbook
  #   print "[#{Time.now}] Generating the PDF file ... "
  #   pdf = PdfCookbook.new(true)
  #   pdf.add_cookbook(self)
  #   puts 'Done'
                                                                                               
  #   # Write the file 
  #   print "[#{Time.now}] Saving the PDF file ... "
  #   t = Time.now
  #   filename = "cookbook_#{order_id}_#{id}-#{t.hour}_#{t.min}_#{t.day}_#{t.month}_#{t.year}.pdf"
  #   pdf.Output("#{PDF_IMAGES_PATH}#{filename}")
  #   pdf = nil
  #   puts 'Done'
    
  #   # Remove the images folder
  #   print "[#{Time.now}] Cleaning up ... "
  #   FileUtils.remove_dir pdf_path if File.exists?(pdf_path)
  #   puts 'Done'
    
  #   # Return the filename
  #   filename
  # end
  
  # def generate_pdf_images(pdf_path)
  #   size = {}
  #   size[:cover] = 0
  #   puts '>> Generating final PDF images:'
  
  #   # Remove the old folder before we begin
  #   FileUtils.remove_dir pdf_path if File.exists? pdf_path
  
  #   # Make the destination path
  #   FileUtils.mkdir_p(pdf_path)
  
  #   # Generate the final images for the pdf
  #   puts 'Generating cover images ... '
  #   size[:cover] += generate_final_image(user_image, "#{pdf_path}#{user_image.name.to_s.pluralize}") if user_image?
  #   size[:cover] += generate_final_image(intro_image, "#{pdf_path}#{intro_image.name.to_s.pluralize}", intro_image_grayscale?) if intro_image?
  #   if self.template.template_type==8
  #     size[:cover] += generate_final_image(user_cover_image, "#{pdf_path}#{user_cover_image.name.to_s.pluralize}") if user_cover_image?
  #     size[:cover] += generate_final_image(user_inner_cover_image, "#{pdf_path}#{user_inner_cover_image.name.to_s.pluralize}", inner_cover_image_grayscale?) if user_inner_cover_image?
  #   end
  #   puts "    [#{number_to_human_size(size[:cover])}]"
  
  #   puts 'Generating section images ... '
  #   size[:section] = {}
  #   sections.each do |section|
  #     new_section = Section.find(section.id)
  #     size[:section][new_section.id] = 0
  #     puts "  -> #{new_section.name}"
  #     if new_section.has_children?
  #       size[:section][new_section.id] += generate_final_image(new_section.photo, "#{pdf_path}sections/#{new_section.id}", self.grayscale?) if new_section.photo?
  #       new_section.recipes.each do |recipe|
  #         size[:section][new_section.id] += generate_final_image(recipe.photo, "#{pdf_path}recipes/#{recipe.id}", recipe.grayscale?) if recipe.photo?
  #       end
  #       new_section.extra_pages.each do |extra_page|
  #         size[:section][new_section.id] += generate_final_image(extra_page.photo, "#{pdf_path}extra_pages/#{extra_page.id}", extra_page.grayscale?) if extra_page.photo?
  #       end
  #       puts "    [#{number_to_human_size(size[:section][new_section.id])}]"    
  #     end
  #   end
  #   puts "Total images size: #{number_to_human_size(size[:cover] + size[:section].collect{|k, v| v}.inject{|a,b| a+b})}"    
  # end
  
  
  # Generates the image if it exists
  # def generate_final_image(image, path, grayscale=false)
  #   FileUtils.mkdir_p(path)
  #   extension = File.extname(image.url)
  #   basename = File.basename(image.url).gsub(/#{extension}$/, '.jpg')
  #   puts "     #{image} => #{basename}"
  #   if grayscale
  #     PdfImage.convert(:grayscale, image.url, "#{path}/#{basename}")
  #   else
  #     PdfImage.convert(nil, image.url, "#{path}/#{basename}")
  #   end
  #   return File.size("#{path}/#{basename}")
  # end

  # Convert an image into greyscale
  def self.generate_grayscale_image(image)
    tmpdir    = Dir.mktmpdir
    extension = File.extname(image)
    filename  = File.basename(image).gsub(/#{extension}$/, '.jpg')
    PdfImage.convert(:grayscale, image, "#{tmpdir}/#{filename}")
    return "#{tmpdir}/#{filename}"
  end
  
  def user_image_from_library?
    self.user_lib_image && self.user_image_source == 'lib'
  end
  
  def user_cover_image_from_library?
    self.user_cover_lib_image && self.user_cover_image_source == 'lib'
  end

  def user_inner_cover_image_from_library?
    self.user_inner_cover_lib_image && self.user_inner_cover_image_source == 'lib'
  end
  
  def intro_image_from_library?
    self.intro_lib_image && self.intro_image_source == 'lib'
  end
  
  def can_be_reordered?
    if paid_orders.empty?
      false
    elsif updated_on.blank?
      true
    elsif updated_on < paid_orders.last.paid_on
      true
    else
      false
    end
  end
  
end
