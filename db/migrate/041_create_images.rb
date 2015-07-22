class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :type,       :string
      t.column :file,       :string
      t.column :grayscale,  :boolean
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
  end

  def self.down
    drop_table :images
  end
end
