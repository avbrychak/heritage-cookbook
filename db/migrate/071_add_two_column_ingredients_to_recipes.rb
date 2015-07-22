class AddTwoColumnIngredientsToRecipes < ActiveRecord::Migration
  def self.up
    add_column :recipes, :ingredients_uses_two_columns, :boolean, :default=>false, :null=>false
    add_column :recipes, :ingredient_list_2, :text
  end

  def self.down
    remove_column :recipes, :ingredients_uses_two_columns
    remove_column :recipes, :ingredient_list_2
  end
end
