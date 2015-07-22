class AddNotesToCookbooks < ActiveRecord::Migration
  def self.up
    add_column :cookbooks, :notes, :text
  end

  def self.down
    remove_column :cookbooks, :notes
  end
end
