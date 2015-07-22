class AddGiftCardTextBlockAndEmail < ActiveRecord::Migration
  def self.up
    Textblock.create(  
      :name         => "email_gift_card_created", 
      :description  => "Email / Gift Card Created",
      :text         => "Dear (=user_name=), 

Congratulations on your purchase! 

Your Gift Crad of (=plan_name=) for (=to=) has been created with the following message:

(=message=)

To redeem your Gift Membership:

1. Login to your account or create a new account
2. Click on 'Add more time' at the top of the page
3. Enter you Gift Card code: (=code=)



Thanks,

Susan",
    :text_html    => "<p>Dear (=user_name=),</p>
      <p>Congratulations on your purchase!</p>
      <p>Your Gift Crad of (=plan_name=) for (=to=) has been created with the following message:</p>
      <p>(=message=)</p>

      <p>To redeem your Gift Membership:</p>
      <ol>
        <li>Login to your account or create a new account</li>
        <li>Click on 'Add more time' at the top of the page</li>
        <li>Enter you Gift Card code: (=code=)</li>
      </ol>
      
      <p>Thanks,</p>
      <p>Susan</p>"
    )
    
    Textblock.create(  
      :name         => "gift_cards", 
      :description  => "Gift Cards",
      :text         => "Fill out the fields bellow:",
      :text_html    => "<p>Fill out the fields bellow:</p>"
    )
    
  rescue
    self.down
    raise
  end

  def self.down
    Textblock.find_by_name('email_gift_card_created').destroy
    Textblock.find_by_name('gift_cards').destroy
  end
end
