class CreateOrdersTable < ActiveRecord::Migration
	def self.up
		create_table "orders" do |t|
			t.column "cookbook_id", :integer, :null => false
			t.column "number_of_books", :integer, :default => 0, :null => false

			t.column "bill_first_name", :string, :limit => 50, :default => "", :null => false
			t.column "bill_last_name", :string, :limit => 50, :default => "", :null => false
			t.column "bill_address", :string, :limit => 50, :default => "", :null => false
			t.column "bill_address2", :string , :default => "", :null => false                     
			t.column "bill_city", :string, :default => "", :null => false
			t.column "bill_zip", :string, :limit => 10, :default => "", :null => false
			t.column "bill_country", :string, :limit => 50, :default => "", :null => false
			t.column "bill_state", :string, :limit => 100, :default => "", :null => false
			t.column "bill_phone", :string, :limit => 15, :default => "", :null => false
			t.column "bill_email", :string, :limit => 100, :default => "", :null => false

			t.column "ship_first_name", :string, :limit => 50, :default => "", :null => false
			t.column "ship_last_name", :string, :limit => 50, :default => "", :null => false
			t.column "ship_address", :string, :limit => 50, :default => "", :null => false
			t.column "ship_address2", :string, :default => "", :null => false
			t.column "ship_city", :string, :default => "", :null => false
			t.column "ship_zip", :string, :limit => 10, :default => "", :null => false
			t.column "ship_country", :string, :limit => 50, :default => "", :null => false
			t.column "ship_state", :string, :limit => 100, :default => "", :null => false
			t.column "ship_phone", :string, :limit => 15, :default => "", :null => false
			t.column "ship_email", :string, :limit => 100, :default => "", :null => false

			t.column "payed_on", :datetime
			t.column "created_on", :datetime
			t.column "updated_on", :datetime
		end
	end

	def self.down
		drop_table :orders
	end
end
