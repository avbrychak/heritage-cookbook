class RenameField < ActiveRecord::Migration
  def self.up
	  rename_column (:orders, 'payed_on', 'paid_on')
  end

  def self.down
	  rename_column (:orders, 'paid_on', 'payed_on')
  end
end
