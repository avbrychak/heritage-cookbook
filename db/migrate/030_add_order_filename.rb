class AddOrderFilename < ActiveRecord::Migration
  def self.up
	add_column "orders", "filename", :string
  end

  def self.down
	remove_column "orders", "filename"
  end
end
