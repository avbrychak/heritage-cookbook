class AddingMoreIndexes < ActiveRecord::Migration
  def self.up
		add_index :textblocks, :name
    add_index :users, [:email, :hashed_password]
    add_index :extra_pages, :section_id
    add_index :extra_pages, :user_id
    add_index :orders, [:cookbook_id, :paid_on]
    change_column :comatose_pages, :full_path, :string
    add_index :comatose_pages, :full_path
  end

  def self.down
    remove_index :textblocks, :name
    remove_index :users, :email
    remove_index :extra_pages, :section_id
    remove_index :extra_pages, :user_id
    remove_index :orders, :cookbook_id
    change_column :comatose_pages, :full_path, :text
    remove_index :comatose_pages, :full_path
  end
end
