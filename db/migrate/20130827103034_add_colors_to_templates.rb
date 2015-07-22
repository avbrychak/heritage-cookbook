class AddColorsToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :cover_color, :string
    add_column :templates, :inner_cover_color, :string
    add_column :templates, :header_color, :string
  end
end
