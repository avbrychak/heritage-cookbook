class AddIndexAsRecipeToExtraPages < ActiveRecord::Migration
  def self.up
    add_column :extra_pages, :index_as_recipe, :boolean, :default => false
  end

  def self.down
    remove_column :extra_pages, :index_as_recipe
  end
end
