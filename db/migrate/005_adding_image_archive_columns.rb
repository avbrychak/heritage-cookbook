class AddingImageArchiveColumns < ActiveRecord::Migration
  def self.up
		add_column "recipes", "photo_archive", :string, :limit => 100, :default => '', :null => false
		add_column "cookbooks", "user_image_archive", :string, :limit => 100, :default => '', :null => false
  end

  def self.down
		remove_column "recipes", "photo_archive"
		remove_column "cookbooks", "user_image_archive"
  end
end
