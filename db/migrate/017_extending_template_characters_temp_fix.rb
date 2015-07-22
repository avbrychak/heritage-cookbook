class ExtendingTemplateCharactersTempFix < ActiveRecord::Migration
	def self.up
		template = Template.find(7)
		template.max_tag_line_1_length = 35
		template.max_tag_line_2_length = 35
		template.max_tag_line_3_length = 35
		template.max_tag_line_4_length = 35
		template.save
	end

	def self.down

	end
end
