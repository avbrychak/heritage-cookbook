class AddDefaultValueForPaidOrdersCount < ActiveRecord::Migration
  def up
    change_column :users, :paid_orders_count, :integer, :default => 0
  end
end
