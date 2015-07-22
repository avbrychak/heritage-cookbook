class UserNumberOfBooks < ActiveRecord::Migration	
	def self.up
		add_column :users, 'number_of_books', :integer, :limit => 11, :default => 0, :null => false	
		
		puts "Updating user table..."
		User.find(:all).each do |user|
			user.update_attribute('number_of_books', user.plan.number_of_books)
			putc "."
		end
		puts
	end
	
	def self.down
		remove_column :users, 'number_of_books'
	end
end