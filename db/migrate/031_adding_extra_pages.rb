class AddingExtraPages < ActiveRecord::Migration
	def self.up
		create_table "extra_pages", :force => true do |t|
			t.column "section_id", :integer, :default => 0, :null => false
			t.column "user_id", :integer, :default => 0, :null => false
			t.column "name", :string, :limit => 100, :default => "", :null => false
			t.column "photo", :string, :default => "", :null => false
		    t.column "grayscale", :integer, :default => 0, :null => false
			t.column "text", :text, :default => "", :null => false
			t.column "pages", :float, :default => 0.0, :null => false
			t.column "created_on", :datetime
			t.column "updated_on", :datetime
		end
	end

	def self.down
		drop_table :extra_pages
	end
end
