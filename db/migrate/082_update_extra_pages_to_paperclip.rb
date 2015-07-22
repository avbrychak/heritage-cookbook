class UpdateExtraPagesToPaperclip < ActiveRecord::Migration
  def self.up
    rename_column :extra_pages, :photo, :photo_file_name
    change_column :extra_pages, :photo_file_name, :string, :null=> true
    add_column :extra_pages, :photo_file_size, :integer
    add_column :extra_pages, :photo_content_type, :string

    if File.exists?(RAILS_ROOT+'/public/extra_page')
      path = "#{RAILS_ROOT}/public/extra_pages/photos/"
      FileUtils.mv(RAILS_ROOT+'/public/extra_page', RAILS_ROOT+'/public/extra_pages')
      FileUtils.mv(RAILS_ROOT+'/public/extra_pages/photo', RAILS_ROOT+'/public/extra_pages/photos')
      Dir.foreach(path) do |dir|
        Dir.foreach(path+dir) do |entry|
          if File.file?("#{path}#{dir}/#{entry}")
            puts "Moving #{entry}"
            FileUtils.mkdir_p("#{path}#{dir}/original")
            FileUtils.mv("#{path}#{dir}/#{entry}", "#{path}#{dir}/original/#{entry}")
          end
        end
        begin
          extra_page = ExtraPage.find(dir)
          FileUtils.mkdir_p("#{path}#{dir}/preview")
          cookbook_file = "#{RAILS_ROOT}/public/images/pdf/cookbook/#{extra_page.section.cookbook_id}/preview/extra_pages/#{extra_page.id}/#{extra_page.photo_file_name}"
          FileUtils.mv(cookbook_file, "#{path}#{dir}/preview") if File.exists?(cookbook_file)
        rescue ActiveRecord::RecordNotFound
          # Ignore it
        end
      end
    end
  rescue
    self.down
    raise
  end

  def self.down
    change_column :extra_pages, :photo_file_name, :string, :null=> false, :default => ''
    rename_column :extra_pages, :photo_file_name, :photo
    remove_column :extra_pages, :photo_file_size
    remove_column :extra_pages, :photo_content_type
  end
end
