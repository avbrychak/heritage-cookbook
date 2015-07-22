class CreateLibImages < ActiveRecord::Migration
  def self.up
    create_table :lib_images do |t|
		t.column :file, :string
    end
  end

  def self.down
    drop_table :lib_images
  end
end
