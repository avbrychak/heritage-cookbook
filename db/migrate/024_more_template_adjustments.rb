class MoreTemplateAdjustments < ActiveRecord::Migration
	def self.up
		template = Template.find(7)
		template.cover_title_font_size = 20
		template.cover_user_image_y = 100
		template.max_tag_line_1_length = 33
		template.max_tag_line_2_length = 33
		template.max_tag_line_3_length = 33
		template.max_tag_line_4_length = 33
		template.headers_font_style = ''
		template.save
	end

	def self.down
	end
end
