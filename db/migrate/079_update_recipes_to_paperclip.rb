class UpdateRecipesToPaperclip < ActiveRecord::Migration
  def self.up
    rename_column :recipes, :photo, :photo_file_name
    change_column :recipes, :photo_file_name, :string, :null=> true
    add_column :recipes, :photo_file_size, :integer
    add_column :recipes, :photo_content_type, :string
    
    if File.exists?(RAILS_ROOT+'/public/recipe')
      path = "#{RAILS_ROOT}/public/recipes/photos/"
      FileUtils.mv(RAILS_ROOT+'/public/recipe', RAILS_ROOT+'/public/recipes')
      FileUtils.mv(RAILS_ROOT+'/public/recipes/photo', RAILS_ROOT+'/public/recipes/photos')
      Dir.foreach(path) do |dir|
        Dir.foreach(path+dir) do |entry|
          if File.file?("#{path}#{dir}/#{entry}")
            puts "Moving #{entry}"
            FileUtils.mkdir_p("#{path}#{dir}/original")
            FileUtils.mv("#{path}#{dir}/#{entry}", "#{path}#{dir}/original/#{entry}")
          end
        end
        begin
          recipe = Recipe.find(dir)
          FileUtils.mkdir_p("#{path}#{dir}/preview")
          cookbook_file = "#{RAILS_ROOT}/public/images/pdf/cookbook/#{recipe.section.cookbook_id}/preview/recipes/#{recipe.id}/#{recipe.photo_file_name}"
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
    change_column :recipes, :photo_file_name, :string, :null=> false, :default => ''
    rename_column :recipes, :photo_file_name, :photo
    remove_column :recipes, :photo_file_size
    remove_column :recipes, :photo_content_type
  end
end
