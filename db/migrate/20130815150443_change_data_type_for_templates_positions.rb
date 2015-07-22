class ChangeDataTypeForTemplatesPositions < ActiveRecord::Migration
  def up
  	change_table :templates do |t|
      t.change :cover_title_y, :float
      t.change :toc_header_y, :float
      t.change :section_header_y, :float
      t.change :inner_cover_title_y, :float
      t.change :section_user_image_y, :float
    end
  end

  def down
  	change_table :templates do |t|
      t.change :cover_title_y, :integer
      t.change :toc_header_y, :integer
      t.change :section_header_y, :integer
      t.change :inner_cover_title_y, :integer
      t.change :section_user_image_y, :integer
    end
  end
end
