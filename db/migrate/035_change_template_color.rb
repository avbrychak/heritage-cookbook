class ChangeTemplateColor < ActiveRecord::Migration
  def self.up
	template = Template.find(5)
	template.book_color = "34,77,112"
	template.save
  end

  def self.down
	template = Template.find(5)
	template.book_color = "0,0,0"
	template.save
  end
end