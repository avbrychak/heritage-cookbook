class CreateBookBindings < ActiveRecord::Migration
  def change
    create_table :book_bindings do |t|
      t.string :name, null: false
      t.integer :max_number_of_pages, null: false

      t.timestamps
    end
  end
end
