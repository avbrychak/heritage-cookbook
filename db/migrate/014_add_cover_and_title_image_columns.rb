class AddCoverAndTitleImageColumns < ActiveRecord::Migration
	class Template < ActiveRecord::Base; end 

	def self.up
		add_column :cookbooks, 'user_cover_image', :string, :default => '', :null => false
		add_column :cookbooks, 'user_inner_cover_image', :string, :default => '', :null => false

		template = Template.find(8)
		template.has_image = 0
		template.save				
	
	end
	
	def self.down
		remove_column :cookbooks, 'user_cover_image'
		remove_column :cookbooks, 'user_inner_cover_image'
	end
end
