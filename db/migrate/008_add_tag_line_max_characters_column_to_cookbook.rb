class AddTagLineMaxCharactersColumnToCookbook < ActiveRecord::Migration

	class Template < ActiveRecord::Base; end 

	def self.up
	  	add_column :templates, 'max_tag_line_1_length', :integer, :limit => 11, :default => 50, :null => false
	  	add_column :templates, 'max_tag_line_2_length', :integer, :limit => 11, :default => 50, :null => false
	  	add_column :templates, 'max_tag_line_3_length', :integer, :limit => 11, :default => 50, :null => false
	  	add_column :templates, 'max_tag_line_4_length', :integer, :limit => 11, :default => 50, :null => false

		template = Template.find(1)
		template.max_tag_line_1_length = 30
		template.save

		template = Template.find(2)
		template.max_tag_line_1_length = 45
		template.save

		template = Template.find(3)
		template.max_tag_line_1_length = 30
		template.save	

		template = Template.find(4)
		template.max_tag_line_1_length = 25
		template.max_tag_line_2_length = 25
		template.save	

		template = Template.find(5)
		template.max_tag_line_1_length = 40
		template.max_tag_line_2_length = 40
		template.save	

		template = Template.find(6)
		template.tag_lines = 3
		template.max_tag_line_1_length = 10
		template.max_tag_line_2_length = 10
		template.max_tag_line_3_length = 5
		template.save	

		template = Template.find(7)
		template.max_tag_line_1_length = 30
		template.max_tag_line_2_length = 30
		template.max_tag_line_3_length = 30
		template.max_tag_line_4_length = 30
		template.save	

		template = Template.find(8)
		template.tag_lines = 0
		template.book_color = '0,0,0'
		template.book_font = 'Times'
		template.cover_title_y = 30
		template.cover_title_font_size = 12
		template.show_book_title_on_inner_cover = 1
		template.headers_font_size = 18
		template.headers_font_style = 'I'
		template.toc_header_y = 50
		template.section_header_y = 68
		template.save				
	end

	def self.down
	  	remove_column :templates, 'max_tag_line_1_length'
	  	remove_column :templates, 'max_tag_line_2_length'
	  	remove_column :templates, 'max_tag_line_3_length'
	  	remove_column :templates, 'max_tag_line_4_length'
	end
end
