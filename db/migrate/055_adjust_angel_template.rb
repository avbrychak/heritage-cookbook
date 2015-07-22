class AdjustAngelTemplate < ActiveRecord::Migration
  def self.up
    add_column :templates, :cover_text_padding_right, :integer, :default => 0
    angel_template = Template.find(6)
    angel_template.update_attributes(:cover_title_y => 37, :cover_text_padding_right => 2)
  rescue
    self.down
  end

  def self.down
    remove_column :templates, :cover_text_padding_right
    angel_template = Template.find(6)
    angel_template.update_attributes(:cover_title_y => 30)
  end
end
