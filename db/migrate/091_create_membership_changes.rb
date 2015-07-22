class CreateMembershipChanges < ActiveRecord::Migration
  
  def self.up
    
    create_table :membership_changes do |t|
      t.integer :user_id
      t.integer :plan_id
      t.integer :number_of_books
      t.date :expiry_date
      t.text :transaction_data
      t.text :notes
      t.timestamps
    end
    
    invalid_records = []

    User.all.each do |user|
      invalid_records << user.id unless user.membership_changes.create(:plan_id => user.plan_id, :expiry_date => user.expiry_date, :transaction_data => user.transaction_data, :number_of_books => user.number_of_books)
    end

    puts("The following records are invalid: " + invalid_records.join(", ")) unless invalid_records.empty?
        
  end

  def self.down
    drop_table :membership_changes
  end
  
end
