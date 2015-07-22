class AddPhotoDimensionsToExtraPages < ActiveRecord::Migration
  def self.up
    add_column :extra_pages, :photo_width, :integer
    add_column :extra_pages, :photo_height, :integer
  end

  def self.down
    remove_column :extra_pages, :photo_height
    remove_column :extra_pages, :photo_width
  end
end
