class AddIndexToCookbook < ActiveRecord::Migration
  def self.up
    add_column :cookbooks, :show_index, :boolean, :default => false
  end

  def self.down
    remove_column :cookbooks, :show_index
  end
end
