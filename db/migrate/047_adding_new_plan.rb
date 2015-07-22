class AddingNewPlan < ActiveRecord::Migration
	def self.up
		Plan.create (	:title 				=> 'Restore Expired Cookbooks for 5 days', 
    				:duration 			=> 1,
    				:price	 			=> 14.95,
    				:number_of_books 	=> 0,
    				:purchaseable		=> 0)	
    puts "Plan created OK"
	end
  
  
  def self.down
		Plan.find_by_title('Restore Expired Cookbooks for 5 days').destroy
    puts "Plan removed OK"
	end
	
end
