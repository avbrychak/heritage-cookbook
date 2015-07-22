class AddExtraOrderFields < ActiveRecord::Migration
  def self.up
    add_column :orders, "order_color_pages", :integer
    add_column :orders, "order_bw_pages", :integer
    add_column :orders, "order_printing_cost", :float
    add_column :orders, "order_shipping_cost", :float
  end

  def self.down
    remove_column :orders, "order_color_pages"
    remove_column :orders, "order_bw_pages"
    remove_column :orders, "order_printing_cost"
    remove_column :orders, "order_shipping_cost"
  end
end