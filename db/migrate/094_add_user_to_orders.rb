class AddUserToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :user_id, :integer
    add_column :users, :paid_orders_count, :integer
    Order.all.each do |o|
      o.update_attribute(:user_id, o.cookbook.owner.id) if (o.cookbook && o.cookbook.owner)
    end
    User.all.each do |u|
      u.update_attribute(:paid_orders_count, u.orders.paid.count)
    end
  end

  def self.down
    remove_column :orders, :user_id
    remove_column :users, :paid_orders_count
  end
end
