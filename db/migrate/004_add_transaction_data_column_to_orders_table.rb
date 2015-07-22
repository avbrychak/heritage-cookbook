class AddTransactionDataColumnToOrdersTable < ActiveRecord::Migration
	
	class Template < ActiveRecord::Base; end 
	
	def self.up
	
		add_column :orders, 'transaction_data', :text
		add_column :templates, 'book_color', :string, :limit => 11, :default => '', :null => false
		add_column :templates, 'book_font', :string, :default => '', :null => false
		add_column :templates, 'cover_title_y', :integer, :default => 0, :null => false
		add_column :templates, 'cover_title_font_size', :integer, :default => 0, :null => false
		add_column :templates, 'show_book_title_on_inner_cover', :integer, :default => 0, :null => false
		add_column :templates, 'headers_font_size', :integer, :default => 0, :null => false
		add_column :templates, 'headers_font_style', :string, :default => '', :null => false
		add_column :templates, 'toc_header_y', :integer, :default => 0, :null => false
		add_column :templates, 'section_header_y', :integer, :default => 0, :null => false
		
		template = Template.find(1)
		template.book_color = '151,53,15'
		template.book_font = 'Times'
		template.cover_title_y = 175
		template.cover_title_font_size = 13
		template.show_book_title_on_inner_cover = 1
		template.headers_font_size = 16
		template.headers_font_style = 'I'
		template.toc_header_y = 50
		template.section_header_y = 70
		template.save
		
		template = Template.find(2)
		template.book_color = '14,16,101'
		template.book_font = 'Arial'
		template.cover_title_y = 88
		template.cover_title_font_size = 14
		template.show_book_title_on_inner_cover = 0
		template.headers_font_size = 20
		template.headers_font_style = 'IB'
		template.toc_header_y = 30
		template.section_header_y = 80
		template.save

		template = Template.find(3)
		template.book_color = '0,0,0'
		template.book_font = 'Times'
		template.cover_title_y = 175
		template.cover_title_font_size = 14
		template.show_book_title_on_inner_cover = 0
		template.headers_font_size = 16
		template.headers_font_style = 'I'
		template.toc_header_y = 50
		template.section_header_y = 70
		template.save

		template = Template.find(4)
		template.book_color = '64,19,148'
		template.book_font = 'Times'
		template.cover_title_y = 120
		template.cover_title_font_size = 12
		template.show_book_title_on_inner_cover = 0
		template.headers_font_size = 18
		template.headers_font_style = 'I'
		template.toc_header_y = 60
		template.section_header_y = 85
		template.save

		template = Template.find(5)
		template.book_color = '0,0,0'
		template.book_font = 'Times'
		template.cover_title_y = 160
		template.cover_title_font_size = 12
		template.show_book_title_on_inner_cover = 0
		template.headers_font_size = 18
		template.headers_font_style = ''
		template.toc_header_y = 50
		template.section_header_y = 68
		template.save
		
		template = Template.find(6)
		template.book_color = '122,94,41'
		template.book_font = 'Times'
		template.cover_title_y = 30
		template.cover_title_font_size = 10
		template.show_book_title_on_inner_cover = 0
		template.headers_font_size = 20
		template.headers_font_style = 'I'
		template.toc_header_y = 70
		template.section_header_y = 68
		template.save

		template = Template.find(7)
		template.book_color = '0,0,0'
		template.book_font = 'Times'
		template.cover_title_y = 30
		template.cover_title_font_size = 12
		template.show_book_title_on_inner_cover = 1
		template.headers_font_size = 18
		template.headers_font_style = 'I'
		template.toc_header_y = 70
		template.section_header_y = 68
		template.save		
	end

	def self.down
		remove_column :orders, 'transaction_data'
		remove_column :templates, 'book_color'
		remove_column :templates, 'book_font'
		remove_column :templates, 'cover_title_y'
		remove_column :templates, 'cover_title_font_size'
		remove_column :templates, 'show_book_title_on_inner_cover'
		remove_column :templates, 'headers_font_size'
		remove_column :templates, 'headers_font_style'
		remove_column :templates, 'toc_header_y'
		remove_column :templates, 'section_header_y'
	end
end
