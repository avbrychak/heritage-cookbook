class AddPaperclipImagesDimensions < ActiveRecord::Migration
  def up
  	add_column :sections, :photo_width, :integer
  	add_column :cookbooks, :intro_image_width, :integer
  	add_column :cookbooks, :user_image_width, :integer
  	add_column :cookbooks, :user_cover_image_width, :integer
  	add_column :cookbooks, :user_inner_cover_image_width, :integer

  	add_column :sections, :photo_height, :integer
  	add_column :cookbooks, :intro_image_height, :integer
  	add_column :cookbooks, :user_image_height, :integer
  	add_column :cookbooks, :user_cover_image_height, :integer
  	add_column :cookbooks, :user_inner_cover_image_height, :integer
  end
end
