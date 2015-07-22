class AddNewTemplateHelpTextblocks < ActiveRecord::Migration
  def self.up
    1.upto(8) do |x|
      Textblock.create(:name => "template_help_#{x}", :description	=> "Template / Help #{x}", :text	=> '')
    end
    textblock = Textblock.find_by_name('template_help_8')
    textblock.text = "NOTE: With this template, unless you are planning on uploading your own custom divider pages, make sure you check the 'Grayscale' box below or you will be charged for color pages for the default dividers, which are grayscale"
    textblock.save
    
    Textblock.create(:name => "cookbook_faq", :description	=> "Cookbook / FAQ", :text	=> 'Coming Soon')
  end

  def self.down
  end
end
