class UpgradeToComatoseV07 < ActiveRecord::Migration

  # Upgrades schema from version 0.6 to version 0.7 
  def self.up
    add_column :comatose_pages, :version, :integer
    create_table :page_versions do |t|
      t.integer :page_versions
      t.integer :page_id
      t.integer :version
      t.integer :parent_id
      t.text :full_path
      t.string :title
      t.string :slug
      t.string :keywords
      t.text :body
      t.string :filter_type, :limit => 25
      t.string :author
      t.integer :position
      t.datetime :updated_on
      t.datetime :created_on
    end
  rescue
    self.down
    rake
  end

  # Downgrades schema from version 0.7 to version 0.6
  def self.down
    remove_column :comatose_pages, :version
    drop_table :page_versions
  end

end
