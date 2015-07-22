class AddImageToSection < ActiveRecord::Migration
  def self.up
    add_column :sections, :section_image_id, :integer
  end

  def self.down
    remove_column :sections, :section_image_id
  end
end
