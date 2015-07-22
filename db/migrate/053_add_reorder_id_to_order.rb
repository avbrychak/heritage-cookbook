class AddReorderIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :reorder_id, :integer
  end

  def self.down
    remove_column :orders, :reorder_id
  end
end
