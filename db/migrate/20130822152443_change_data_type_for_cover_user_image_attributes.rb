class ChangeDataTypeForCoverUserImageAttributes < ActiveRecord::Migration
  def up
  	change_column :templates, :cover_user_image_y,          :float, null: true
  	change_column :templates, :cover_user_image_max_height, :float, null: true
  	change_column :templates, :cover_user_image_max_width,  :float, null: true
  end

  def down
  	change_column :templates, :cover_user_image_y,          :integer, null: false
  	change_column :templates, :cover_user_image_max_height, :integer, null: false
  	change_column :templates, :cover_user_image_max_width,  :integer, null: false
  end
end
