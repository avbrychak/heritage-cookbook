class AddFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :has_been_contacted, :boolean, :default => false
    add_column :users, :notes, :text
  end

  def self.down
    remove_column :users, :notes
    remove_column :users, :has_been_contacted
  end
end
