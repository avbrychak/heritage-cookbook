class AddIsLockedForPrintingToCookbooks < ActiveRecord::Migration
  def self.up
    add_column :cookbooks, :is_locked_for_printing, :boolean, :default => 0
  end

  def self.down
    remove_column :cookbooks, :is_locked_for_printing
  end
end
