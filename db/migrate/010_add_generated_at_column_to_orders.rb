class AddGeneratedAtColumnToOrders < ActiveRecord::Migration
	def self.up
	  	add_column :orders, 'generated_at', :datetime
	end
	
	def self.down
	  	remove_column :orders, 'generated_at'
	end
end
