class AddingSubmittedByTitle < ActiveRecord::Migration
  def self.up
	add_column :recipes, 'submitted_by_title', :string, :default => 'Submitted by:', :null => false
  end

  def self.down
	remove_column :recipes, 'submitted_by_title'
  end
end
