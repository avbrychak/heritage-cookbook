class AdjustingTemplate8 < ActiveRecord::Migration
  def self.up
    template = Template.find(8)
		template.toc_header_y = 60
		template.save
  end

  def self.down
    template = Template.find(8)
		template.toc_header_y = 50
		template.save
  end
end
