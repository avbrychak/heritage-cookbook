class RemoveTokenFromOrders < ActiveRecord::Migration
  def change
  	remove_column :orders, :token
  end
end
