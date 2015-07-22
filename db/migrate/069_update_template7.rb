class UpdateTemplate7 < ActiveRecord::Migration
  def self.up
    template = Template.find(7)
    template.update_attribute(:cover_title_y, 33)
  end

  def self.down
    template = Template.find(7)
    template.update_attribute(:cover_title_y, 30)
  end
end
