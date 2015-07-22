class AddForceOwnPageToRecipes < ActiveRecord::Migration
	def self.up
		add_column :recipes, 'force_own_page', :integer
	end
	
	def self.down
		remove_column :recipes, 'force_own_page'
	end
end
