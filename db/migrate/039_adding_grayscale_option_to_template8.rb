class AddingGrayscaleOptionToTemplate8 < ActiveRecord::Migration
  def self.up
    add_column :cookbooks, "inner_cover_image_grayscale", :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :cookbooks, 'inner_cover_image_grayscale'
  end
end
