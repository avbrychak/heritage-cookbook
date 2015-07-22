class AddExpiredColumn < ActiveRecord::Migration	
	def self.up
		add_column :cookbooks, 'expired', :integer, :limit => 1, :default => 0, :null => false	
	end
	
	def self.down
		remove_column :cookbooks, 'expired'
	end
end