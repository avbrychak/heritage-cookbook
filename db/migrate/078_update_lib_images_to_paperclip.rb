class UpdateLibImagesToPaperclip < ActiveRecord::Migration
  def self.up
    rename_column :lib_images, :file, :lib_image_file_name
    add_column :lib_images, :lib_image_file_size, :integer
    add_column :lib_images, :lib_image_content_type, :string
    
    if File.exists?(RAILS_ROOT+'/public/lib_image')
      FileUtils.mv(RAILS_ROOT+'/public/lib_image/file', RAILS_ROOT+'/public/lib_images')
      FileUtils.remove_dir(RAILS_ROOT+'/public/lib_image')
      Dir.foreach(RAILS_ROOT+'/public/lib_images') do |dir|
        Dir.foreach(RAILS_ROOT+'/public/lib_images/'+dir) do |entry|
          if File.file?("#{RAILS_ROOT}/public/lib_images/#{dir}/#{entry}")
            puts "Moving #{entry}"
            FileUtils.mkdir_p("#{RAILS_ROOT}/public/lib_images/#{dir}/original")
            FileUtils.mv("#{RAILS_ROOT}/public/lib_images/#{dir}/#{entry}", "#{RAILS_ROOT}/public/lib_images/#{dir}/original/#{entry}")
          end
        end
      end
    end
  rescue
    self.down
  end

  def self.down
    rename_column :lib_images, :lib_image_file_name, :file
    remove_column :lib_images, :lib_image_file_size
    remove_column :lib_images, :lib_image_content_type
  end
end
