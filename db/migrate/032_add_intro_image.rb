class AddIntroImage < ActiveRecord::Migration
  def self.up
	add_column "cookbooks", "intro_image", :string
	add_column "cookbooks", "intro_image_grayscale", :integer, :default => 0, :null => false
  end

  def self.down
	remove_column "cookbooks", "intro_image"
	remove_column "cookbooks", "intro_image_grayscale"
  end
end
