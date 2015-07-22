class AddPositionToTemplates < ActiveRecord::Migration
  def change
  	add_column :templates, :position, :integer, unique: true
  end
end
