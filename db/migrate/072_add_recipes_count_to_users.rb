class AddRecipesCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :recipes_count, :integer, :default => 0
    User.reset_column_information
    User.find(:all).each do |u|
      u.update_attribute :recipes_count, u.recipes.length
    end
  end

  def self.down
    remove_column :users, :recipes_count
  end
end
