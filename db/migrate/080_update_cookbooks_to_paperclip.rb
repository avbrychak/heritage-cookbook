class UpdateCookbooksToPaperclip < ActiveRecord::Migration
  def self.up
    remove_column :cookbooks, :user_title_image
    remove_column :cookbooks, :custom_tag_line_1
    remove_column :cookbooks, :custom_tag_line_2
    remove_column :cookbooks, :custom_tag_line_3
    remove_column :cookbooks, :custom_tag_line_4
    remove_column :cookbooks, :user_image_archive
    
    rename_column :cookbooks, :user_image, :user_image_file_name
    change_column :cookbooks, :user_image_file_name, :string, :null=> true
    add_column :cookbooks, :user_image_file_size, :integer
    add_column :cookbooks, :user_image_content_type, :string
    
    rename_column :cookbooks, :user_cover_image, :user_cover_image_file_name
    change_column :cookbooks, :user_cover_image_file_name, :string, :null=> true
    add_column :cookbooks, :user_cover_image_file_size, :integer
    add_column :cookbooks, :user_cover_image_content_type, :string
    
    rename_column :cookbooks, :user_inner_cover_image, :user_inner_cover_image_file_name
    change_column :cookbooks, :user_inner_cover_image_file_name, :string, :null=> true
    add_column :cookbooks, :user_inner_cover_image_file_size, :integer
    add_column :cookbooks, :user_inner_cover_image_content_type, :string
    
    rename_column :cookbooks, :intro_image, :intro_image_file_name
    change_column :cookbooks, :intro_image_file_name, :string, :null=> true
    add_column :cookbooks, :intro_image_file_size, :integer
    add_column :cookbooks, :intro_image_content_type, :string
    
    if File.exists?(RAILS_ROOT+'/public/cookbook')
      path = "#{RAILS_ROOT}/public/cookbooks"
      FileUtils.mv(RAILS_ROOT+'/public/cookbook', path)
      %w{user_image user_cover_image user_inner_cover_image intro_image}.each do |image_name|
        puts "=========================> #{image_name}"
        FileUtils.mv("#{path}/#{image_name}", "#{path}/#{image_name}s")
        FileUtils.remove_dir("#{path}/#{image_name}s/tmp", :force => true)
        Dir.foreach("#{path}/#{image_name}s") do |dir|
          Dir.foreach("#{path}/#{image_name}s/#{dir}") do |entry|
            if File.file?("#{path}/#{image_name}s/#{dir}/#{entry}")
              puts "Moving #{entry} ===> #{path}/#{image_name}s/#{dir}/original/#{entry}"
              FileUtils.mkdir_p("#{path}/#{image_name}s/#{dir}/original")
              FileUtils.mv("#{path}/#{image_name}s/#{dir}/#{entry}", "#{path}/#{image_name}s/#{dir}/original/#{entry}")
            end
          end
          begin
            cookbook = Cookbook.find(dir)
            FileUtils.mkdir_p("#{path}/#{image_name}s/#{dir}/preview")
            file_name = cookbook.send("#{image_name}_file_name")
            src_path = "#{RAILS_ROOT}/public/images/pdf/cookbook/#{cookbook.id}/preview/#{image_name == 'user_image' ? 'cover' : image_name}/#{file_name}"
            if !file_name.blank? && File.exists?(src_path)
              puts "Moving #{src_path} ===> #{path}/#{image_name}s/#{dir}/preview/#{file_name}"
              FileUtils.mv(src_path, "#{path}/#{image_name}s/#{dir}/preview/#{file_name}") 
            end
          rescue ActiveRecord::RecordNotFound
            puts "Failed to find Cookbook with id: #{dir}"
          end
        end
      end
    end
  rescue
    self.down
    raise
  end

  def self.down
    add_column :cookbooks, :user_title_image, :string, :null => false, :default => ''
    add_column :cookbooks, :custom_tag_line_1, :string, :null => false, :default => ''
    add_column :cookbooks, :custom_tag_line_2, :string, :null => false, :default => ''
    add_column :cookbooks, :custom_tag_line_3, :string, :null => false, :default => ''
    add_column :cookbooks, :custom_tag_line_4, :string, :null => false, :default => ''
    add_column :cookbooks, :user_image_archive, :string, :null => false, :default => ''
    
    change_column :cookbooks, :user_image_file_name, :string, :null=> false, :default => ''
    rename_column :cookbooks, :user_image_file_name, :user_image
    remove_column :cookbooks, :user_image_file_size
    remove_column :cookbooks, :user_image_content_type
    
    change_column :cookbooks, :user_cover_image_file_name, :string, :null=> false, :default => ''
    rename_column :cookbooks, :user_cover_image_file_name, :user_cover_image
    remove_column :cookbooks, :user_cover_image_file_size
    remove_column :cookbooks, :user_cover_image_content_type
    
    change_column :cookbooks, :user_inner_cover_image_file_name, :string, :null=> false, :default => ''
    rename_column :cookbooks, :user_inner_cover_image_file_name, :user_inner_cover_image
    remove_column :cookbooks, :user_inner_cover_image_file_size
    remove_column :cookbooks, :user_inner_cover_image_content_type
    
    change_column :cookbooks, :intro_image_file_name, :string, :null=> false, :default => ''
    rename_column :cookbooks, :intro_image_file_name, :intro_image
    remove_column :cookbooks, :intro_image_file_size
    remove_column :cookbooks, :intro_image_content_type
  end
end
