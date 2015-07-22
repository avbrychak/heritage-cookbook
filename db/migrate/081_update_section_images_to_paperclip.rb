class UpdateSectionImagesToPaperclip < ActiveRecord::Migration
  def self.up
    if File.exists?(RAILS_ROOT+'/public/image')
      puts 'Rename the folder to user the section id'
      result = select_all("SELECT * from sections WHERE section_image_id IS NOT NULL")
      result.each do |section|
        src_path = "#{RAILS_ROOT}/public/image/file/"
        if File.exists?("#{src_path}#{section['section_image_id']}")
          FileUtils.mv("#{src_path}#{section['section_image_id']}", "#{src_path}#{section['id']}")
        end
      end
    
      puts 'Renaming the main folder'
      path = "#{RAILS_ROOT}/public/sections/photos/"
      FileUtils.mv(RAILS_ROOT+'/public/image', RAILS_ROOT+'/public/sections')
      FileUtils.mv(RAILS_ROOT+'/public/sections/file', RAILS_ROOT+'/public/sections/photos')
      Dir.foreach(path) do |dir|
        if dir!='.' && dir !='..'
          FileUtils.mv("#{path}#{dir}/pdf_preview", "#{path}#{dir}/preview")
          FileUtils.remove_dir("#{path}#{dir}/pdf_preview_grayscale")
          FileUtils.remove_dir("#{path}#{dir}/thumb_grayscale")
        end
        Dir.foreach(path+dir) do |entry|
          if File.file?("#{path}#{dir}/#{entry}")
            puts "Moving #{entry}"
            FileUtils.mkdir_p("#{path}#{dir}/original")
            FileUtils.mv("#{path}#{dir}/#{entry}", "#{path}#{dir}/original/#{entry}")
          end
        end
      end
    end

    add_column :sections, :photo_file_name    , :string
    add_column :sections, :photo_file_size    , :integer
    add_column :sections, :photo_content_type , :string
    execute("UPDATE sections LEFT JOIN heritage_images ON(sections.section_image_id = heritage_images.id) SET sections.photo_file_name=heritage_images.file")
    #remove_column :sections, :section_image_id
    
    drop_table :heritage_images
    
    
  rescue
    self.down
    raise
  end

  def self.down
    remove_column :sections, :photo_file_name   
    remove_column :sections, :photo_file_size   
    remove_column :sections, :photo_content_type
    # add_column :sections, :section_image_id    , :integer
    
    create_table "heritage_images", :force => true do |t|
      t.string   "type"
      t.string   "file"
      t.boolean  "grayscale"
      t.datetime "created_on"
      t.datetime "updated_on"
    end
  end
end
