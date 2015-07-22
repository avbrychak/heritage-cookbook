class AddSectionImageSizesToTemplate < ActiveRecord::Migration
  def self.up
    add_column :templates, 'section_user_image_y', :integer    
    add_column :templates, 'section_user_image_max_width', :integer
    add_column :templates, 'section_user_image_max_height', :integer
	
		template = Template.find(1)
		template.section_user_image_y = 90
		template.section_user_image_max_width = 80
		template.section_user_image_max_height = 95
		template.save
		
		template = Template.find(2)
		template.section_user_image_y = 100
		template.section_user_image_max_width = 90
		template.section_user_image_max_height = 100
		template.save
		
		template = Template.find(3)
		template.section_user_image_y = 90
		template.section_user_image_max_width = 90
		template.section_user_image_max_height = 100
		template.save
		
		template = Template.find(4)
		template.section_user_image_y = 100
		template.section_user_image_max_width = 90
		template.section_user_image_max_height = 55
		template.save
		
		template = Template.find(5)
		template.section_user_image_y = 105
		template.section_user_image_max_width = 100
		template.section_user_image_max_height = 100
		template.save
		
		template = Template.find(6)
		template.section_user_image_y = 90
		template.section_user_image_max_width = 100
		template.section_user_image_max_height = 100
		template.save
		
		template = Template.find(7)
		template.section_user_image_y = 95
		template.section_user_image_max_width = 70
		template.section_user_image_max_height = 90
		template.save
  end

  def self.down
    remove_column :templates, 'section_user_image_y'
    remove_column :templates, 'section_user_image_max_width'
    remove_column :templates, 'section_user_image_max_height'
  end
end
