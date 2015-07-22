class NewPricingModel < ActiveRecord::Migration
  def self.up
    ['1 Month Membership', '5 Month Membership', '1 Year Membership'].each do |plan_name|
      p = Plan.find_by_title(plan_name)
      p.purchaseable = 0
      p.save
    end
    puts "Turned off old plans OK"
    
		Plan.create (	:title 				=> '2 Month Membership', 
    				:duration 			=> 2,
    				:price	 			=> 29.95,
    				:number_of_books 	=> 1,
    				:purchaseable		=> 1)	
		Plan.create (	:title 				=> '4 Month Membership', 
    				:duration 			=> 4,
    				:price	 			=> 39.95,
    				:number_of_books 	=> 2,
    				:purchaseable		=> 1)
		Plan.create (	:title 				=> '1 Year Membership', 
    				:duration 			=> 12,
    				:price	 			=> 59.95,
    				:number_of_books 	=> 3,
    				:purchaseable		=> 1)
		Plan.create (	:title 				=> '1 Month Membership Upgrade', 
    				:duration 			=> 1,
    				:price	 			=> 9.95,
    				:number_of_books 	=> 3,
    				:purchaseable		=> 0)
    puts "Plans created OK"
  end

  def self.down
    %w{2 3 4}.each do |plan_number|
      p = Plan.find plan_number
      p.purchaseable = 1
      p.save
    end
    
    %w{8 9 10 11}.each do |plan_number|
      Plan.find(plan_number).destroy
    end    
  end
end
