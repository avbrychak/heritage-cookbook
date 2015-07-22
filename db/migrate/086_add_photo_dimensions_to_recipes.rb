class AddPhotoDimensionsToRecipes < ActiveRecord::Migration
  def self.up
    add_column :recipes, :photo_width, :integer
    add_column :recipes, :photo_height, :integer
  end

  def self.down
    remove_column :recipes, :photo_height
    remove_column :recipes, :photo_width
  end
end
