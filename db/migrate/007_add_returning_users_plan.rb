class AddReturningUsersPlan < ActiveRecord::Migration
  def self.up
  	Plan.create (	:title	=> 'Returning User + 1 Free Month Membership', 
					:duration => 1,
					:price	=> 0.00,
					:number_of_books 	=> 3,
					:purchaseable => 0)
  	end

  def self.down
	p = Plan.find_by_title('Returning User + 1 Free Month Membership')
  	p.destroy
  end
end
