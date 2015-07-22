class CreateGiftCards < ActiveRecord::Migration
  def self.up
    create_table :gift_cards do |t|
      t.column :plan_id,          :integer
      t.column :user_id,          :integer
      t.column :code,             :string, :null => false, :default => ''
      t.column :bill_name,        :string, :null => false, :default => ''
      t.column :bill_address,     :string, :null => false, :default => ''
      t.column :bill_city,        :string, :null => false, :default => ''
      t.column :bill_postal_code, :string, :null => false, :default => ''
      t.column :bill_state,       :string, :null => false, :default => ''
      t.column :bill_country,     :string, :null => false, :default => ''
      t.column :bill_phone,       :string, :null => false, :default => ''
      t.column :bill_email,       :string, :null => false, :default => ''
      t.column :to,               :string, :null => false, :default => ''
      t.column :message,          :string, :null => false, :default => ''
      t.column :is_paid,          :boolean, :null => false, :default => false
      t.column :transaction_data, :string, :null => false, :default => ''
      t.column :created_on,       :datetime
      t.column :redeemed_on,      :datetime
    end
    
    add_index :gift_cards, :plan_id
    add_index :gift_cards, :code
  end

  def self.down
    drop_table :gift_cards
  end
end
