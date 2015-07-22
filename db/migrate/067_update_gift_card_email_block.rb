class UpdateGiftCardEmailBlock < ActiveRecord::Migration
  def self.up
    text_block = Textblock.find_by_name('email_gift_card_created')
    
    text_block.text = "Dear (=user_name=), 

Congratulations on your purchase! 

Your Gift Membership of (=plan_name=) for (=friend_name=) has been created with the following message:

(=message=)

(=friend_name=) will recive an email at (=friend_email=) on (=gift_card_date=) with instructions on how to redeem the 
Gift Membership. 


Thanks,

Susan"
    text_block.text_html = "<p>Dear (=user_name=),</p>
      <p>Congratulations on your purchase!</p>
      <p>Your Gift Membership of (=plan_name=) for (=friend_name=) has been created with the following message:</p>
      <p>(=message=)</p>

      <p>(=friend_name=) will recive an email at (=friend_email=) on (=gift_card_date=) with instructions on 
      how to redeem the Gift Membership.</p>
      
      <p>Thanks,</p>
      <p>Susan</p>"
    text_block.save
    
  rescue
    self.down
    raise
  end

  def self.down
  end
end
