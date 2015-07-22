class AddTokenToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :token, :string, unique: true
  	add_index :orders, :token
  end
end
