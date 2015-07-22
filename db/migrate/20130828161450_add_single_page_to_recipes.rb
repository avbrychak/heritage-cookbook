class AddSinglePageToRecipes < ActiveRecord::Migration
  def change
  	add_column :recipes, :single_page, :boolean
  end
end
