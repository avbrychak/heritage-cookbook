class AddPaypalExpressCheckoutAttributesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :express_token, :string
    add_column :users, :express_payer_id, :string
    add_column :membership_changes, :express_token, :string
    add_column :membership_changes, :express_payer_id, :string
  end

  def self.down
    remove_column :users, :express_payer_id
    remove_column :users, :express_token
    remove_column :membership_changes, :express_token
    remove_column :membership_changes, :express_payer_id
  end
end
