class AddingCenteredIntroduction < ActiveRecord::Migration
  def self.up
	add_column :cookbooks, 'center_introduction', :boolean, :default => 0
  end

  def self.down
	remove_column :cookbooks, 'center_introduction'
  end
end
