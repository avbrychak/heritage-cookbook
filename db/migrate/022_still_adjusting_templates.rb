class StillAdjustingTemplates < ActiveRecord::Migration
	def self.up
		template = Template.find(7)
		template.cover_title_y = 32
		template.cover_title_font_size = 19
		template.cover_user_image_max_height = 110
		template.cover_user_image_max_width = 110
		template.cover_title_font_style = ''
		template.save
	end

	def self.down
	end
end
