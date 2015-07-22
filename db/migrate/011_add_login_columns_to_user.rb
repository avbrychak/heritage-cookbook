class AddLoginColumnsToUser < ActiveRecord::Migration
	class Template < ActiveRecord::Base; end 
	def self.up
		add_column :users, 'created_on', :datetime
		add_column :users, 'last_login_on', :datetime
		add_column :users, 'login_count', :integer, :default => 0, :null => false

		template = Template.find(1)
		template.headers_font_size = 20
		template.save

		template = Template.find(3)
		template.headers_font_size = 20
		template.save

		template = Template.find(4)
		template.headers_font_size = 20
		template.save

		template = Template.find(5)
		template.headers_font_size = 20
		template.save

		template = Template.find(7)
		template.headers_font_size = 20
		template.show_book_title_on_inner_cover = 0
		template.toc_header_y = 60
		template.save

		template = Template.find(8)
		template.headers_font_size = 20
		template.show_book_title_on_inner_cover = 0
		template.toc_header_y = 50
		template.save

	end
	
	def self.down
	  	remove_column :users, 'created_on'
	  	remove_column :users, 'last_login_on'
	  	remove_column :users, 'login_count'
	end
end
