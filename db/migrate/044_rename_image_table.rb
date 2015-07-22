class RenameImageTable < ActiveRecord::Migration
  def self.up
    rename_table :images, :heritage_images
  end

  def self.down
    rename_table :heritage_images, :images
  end
end
