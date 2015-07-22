class AddBookBindingToCookbooks < ActiveRecord::Migration
  def change
    add_column :cookbooks, :book_binding_id, :integer, default: 1
    add_index :cookbooks, :book_binding_id
  end
end
