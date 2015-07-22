class AddPaperclipImagesDpi < ActiveRecord::Migration
  def up
  	add_column :recipes, :photo_dpi, :integer
  	add_column :extra_pages, :photo_dpi, :integer
  	add_column :sections, :photo_dpi, :integer
  	add_column :cookbooks, :intro_image_dpi, :integer
  	add_column :cookbooks, :user_image_dpi, :integer
  	add_column :cookbooks, :user_cover_image_dpi, :integer
  	add_column :cookbooks, :user_inner_cover_image_dpi, :integer
  end
end
