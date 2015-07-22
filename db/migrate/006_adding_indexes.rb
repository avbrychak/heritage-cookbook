class AddingIndexes < ActiveRecord::Migration
  def self.up
		add_index :authorships, :user_id
		add_index :authorships, :cookbook_id
		add_index :recipes, 		:section_id
		add_index :recipes, 		:user_id
		add_index :sections,		:cookbook_id
  end

  def self.down
		remove_index :authorships, :user_id
		remove_index :authorships, :cookbook_id
		remove_index :recipes, 		:section_id
		remove_index :recipes, 		:user_id
		remove_index :sections,		:cookbook_id
  end
end
