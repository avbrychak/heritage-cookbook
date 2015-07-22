class ChangeTemplateConfiguration < ActiveRecord::Migration
	class Template < ActiveRecord::Base; end 

	def self.up
		template = Template.find(7)
		template.show_book_title_on_inner_cover = 1
		template.cover_title_y = 50
		template.save				
	
	end
	
	def self.down
	end
end
