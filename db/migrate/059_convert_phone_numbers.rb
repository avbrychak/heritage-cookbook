class ConvertPhoneNumbers < ActiveRecord::Migration
  extend ActionView::Helpers::NumberHelper
  
  def self.up
    add_column :users, :old_phone, :string, :null=> false, :default => ''
    puts 'Converting users phone numbers. This may take a while. Please wait ...'
    User.find(:all).each do |user|
      user.old_phone = user.phone
      user.phone = number_to_phone(user.phone.gsub(/^1\-/, '').gsub(/[^\d]/, '').to_i)
      user.phone = '' if user.phone == '0' || !user.phone['-']
      user.save
    end
    puts 'Done!'
    
    add_column :orders, :old_ship_phone, :string, :null=> false, :default => ''
    add_column :orders, :old_bill_phone, :string, :null=> false, :default => ''
    puts 'Converting orders phone numbers. This may take a while. Please wait ...'
    Order.find(:all).each do |order|
      order.old_ship_phone = order.ship_phone || ''
      order.ship_phone = number_to_phone(order.ship_phone.gsub(/^1\-/, '').gsub(/[^\d]/, '').to_i)
      order.ship_phone = '' if order.ship_phone == '0' || !order.ship_phone['-']

      order.old_bill_phone = order.bill_phone || ''
      order.bill_phone = number_to_phone(order.bill_phone.gsub(/^1\-/, '').gsub(/[^\d]/, '').to_i)
      order.bill_phone = '' if order.bill_phone == '0' || !order.bill_phone['-']

      order.save
    end
    puts 'Done!'
    
  rescue
    self.down
    raise
  end

  def self.down
    remove_column :users, :phone
    rename_column :users, :old_phone, :phone

    remove_column :orders, :ship_phone
    rename_column :orders, :old_ship_phone, :ship_phone
    remove_column :orders, :bill_phone
    rename_column :orders, :old_bill_phone, :bill_phone
  end
end
