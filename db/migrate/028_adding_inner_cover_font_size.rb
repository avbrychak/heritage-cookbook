class AddingInnerCoverFontSize < ActiveRecord::Migration
  def self.up
	add_column :templates, 'inner_cover_font_size', :integer, :limit => 11, :default => 0, :null => false
	
	Template.reset_column_information

    Template.find(:all).each do |template|
		template.inner_cover_font_size = template.cover_title_font_size
		template.save
    end

	template = Template.find(7)
	template.inner_cover_font_size = 18
	template.save

  end

  def self.down
	remove_column :templates, 'inner_cover_font_size'
  end
end
