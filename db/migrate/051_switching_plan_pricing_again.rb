class SwitchingPlanPricingAgain < ActiveRecord::Migration
  def self.up
    Plan.update_all('purchaseable = 0, upgradeable = 0', "id != 1")
    puts "Turned off old plans OK"
    
		Plan.create (	:title 				=> '1 Month Membership', 
    				:duration 			=> 1,
    				:price	 			=> 29.95,
    				:number_of_books 	=> 1,
    				:purchaseable		=> 1,
    				:upgradeable => 1)	
		Plan.create (	:title 				=> '2 Month Membership', 
    				:duration 			=> 2,
    				:price	 			=> 39.95,
    				:number_of_books 	=> 1,
    				:purchaseable		=> 1,
    				:upgradeable => 1)
		Plan.create (	:title 				=> '4 Month Membership', 
    				:duration 			=> 4,
    				:price	 			=> 49.95,
    				:number_of_books 	=> 2,
    				:purchaseable		=> 1,
    				:upgradeable => 1)
		Plan.create (	:title 				=> '1 Year Membership', 
    				:duration 			=> 12,
    				:price	 			=> 59.95,
    				:number_of_books 	=> 3,
    				:purchaseable		=> 1,
    				:upgradeable => 1)
		Plan.create (	:title 				=> '1 Month Membership Upgrade', 
    				:duration 			=> 1,
    				:price	 			=> 19.95,
    				:number_of_books 	=> 3,
    				:purchaseable		=> 0,
    				:upgradeable => 1)
    puts "New Plans created OK"
    
    
  end

  def self.down
  end
end
