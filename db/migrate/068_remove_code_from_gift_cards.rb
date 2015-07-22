class RemoveCodeFromGiftCards < ActiveRecord::Migration
  def self.up
    remove_column :gift_cards, :code
    add_column :gift_cards, :notified_on, :datetime
    
    Textblock.create(  
      :name         => "email_gift_card_notification", 
      :description  => "Email / Gift Card Notification",
      :text         => "Dear (=user_name=), 

Congratulations! 

(=friend_name=) has offered you a (=plan_name=) on Heritage Cookbook website.

(=message=)

Your membership will begin as soon as you login to your acount.
  
To redeem your Gift Membership just go to http://www.heritagecookbook.com/account/login and login into your account.

If this your first time or if you can't remember your password just go to http://www.heritagecookbook.com/account/forgot_password and enter you email so we can send you a new password.

If you have any questions, please don't hesitate to contact me.",
        :text_html    => "<p>Dear (=user_name=),</p>
          <p>Congratulations!</p>
          <p>(=friend_name=) has offered you a (=plan_name=) on Heritage Cookbook website.</p>
          <p>(=message=)</p>

          <p>
            Your membership will begin as soon as you login to your acount.
            <br/>To redeem your Gift Membership just go to http://www.heritagecookbook.com/account/login and login into your account.
          </p>
          <p>If this your first time or if you can't remember your password just go to http://www.heritagecookbook.com/account/forgot_password and enter you email so we can send you a new password.</p>
          <p>If you have any questions, please don't hesitate to contact me.</p>"
    )

  rescue
    self.down
    raise
  end

  def self.down
    add_column :gift_cards, :code, :string, :null => false, :default => ''
    remove_column :gift_cards, :notified_on
    Textblock.find_by_name('email_gift_card_notification').destroy
  end
end
