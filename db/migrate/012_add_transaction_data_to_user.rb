class AddTransactionDataToUser < ActiveRecord::Migration
	def self.up
		add_column :users, 'transaction_data', :text
	end
	
	def self.down
		remove_column :users, 'transaction_data'
	end
end
