class ReworkingDesignTemplatesABit < ActiveRecord::Migration
	def self.up
		add_column :templates, 'cover_title_font_style', :string, :default => '', :null => false
		add_column :templates, 'inner_cover_title_y', :integer, :default => 0, :null => false
		remove_column :templates, 'config_file'
	
		# Set the new fields values
		templates = Template.find :all
		templates.each do |template|
			template.cover_title_font_style = 'I'
			template.inner_cover_title_y = template.cover_title_y
			template.save
		end
	
		# Reworking the designs a little bit
		template = Template.find(1)
		template.tag_lines = 2
		template.max_tag_line_1_length = 26
		template.max_tag_line_2_length = 26
		template.save

		template = Template.find(2)
		template.tag_lines = 2
		template.max_tag_line_2_length = 45
		template.save

		template = Template.find(3)
		template.tag_lines = 2
		template.max_tag_line_2_length = 30
		template.save

		template = Template.find(4)
		template.toc_header_y = 65
		template.save

		template = Template.find(6)
		template.max_tag_line_2_length = 8
		template.save
	
		template = Template.find(7)
		template.cover_title_y = 35
		template.cover_title_font_size = 15
		template.cover_user_image_max_height = 117
		template.cover_title_font_style = 'IB'
		template.inner_cover_title_y = 60
		template.save

	end

	def self.down
		remove_column :templates, 'inner_cover_title_y'
		remove_column :templates, 'cover_title_font_style'
		add_column :templates, 'config_file', :string, :limit => 50, :default => '', :null => false
	end
end
