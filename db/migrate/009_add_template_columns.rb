class AddTemplateColumns < ActiveRecord::Migration
	class Template < ActiveRecord::Base; end 
	def self.up
	  	add_column :templates, 'cover_user_image_y', :integer, :limit => 11, :default => 0, :null => false
	  	add_column :templates, 'cover_user_image_max_width', :integer, :limit => 11, :default => 0, :null => false
	  	add_column :templates, 'cover_user_image_max_height', :integer, :limit => 11, :default => 0, :null => false

		template = Template.find(1)
		template.cover_user_image_y = 95
		template.cover_user_image_max_width = 73
		template.cover_user_image_max_height = 60
		template.save

		template = Template.find(7)
		template.cover_user_image_y = 90
		template.cover_user_image_max_width = 128
		template.cover_user_image_max_height = 130
		template.save

		template = Template.find(8)
		template.cover_user_image_y = 13
		template.cover_user_image_max_width = 126
		template.cover_user_image_max_height = 200
		template.save
	end

	def self.down
	  	remove_column :templates, 'cover_user_image_y'
	  	remove_column :templates, 'cover_user_image_max_width'
	  	remove_column :templates, 'cover_user_image_max_height'
	end
end
