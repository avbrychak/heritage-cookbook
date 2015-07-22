class AddColumnIsOldUserToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_old_user, :boolean, :default => true
  end

  def self.down
    remove_column :users, :is_old_user
  end
end
