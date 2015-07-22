class AddBookBindingAndCookbookTitleToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :book_binding, :string
  	add_column :orders, :cookbook_title, :string
  end
end
