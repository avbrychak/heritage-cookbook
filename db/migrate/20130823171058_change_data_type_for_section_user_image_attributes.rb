class ChangeDataTypeForSectionUserImageAttributes < ActiveRecord::Migration
  def up
  	change_column :templates, :section_user_image_max_height, :float
  	change_column :templates, :section_user_image_max_width,  :float
  end

  def down
  	change_column :templates, :section_user_image_max_height, :integer
  	change_column :templates, :section_user_image_max_width,  :integer
  end
end
