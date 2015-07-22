class AddVersionToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :version, :integer, :default=>1, :null=>false
  end

  def self.down
    remove_column :orders, :version
  end
end
