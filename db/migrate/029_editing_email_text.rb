class EditingEmailText < ActiveRecord::Migration
	def self.up
		block = Textblock.find_by_name 'email_signup_details'
		block.text = 'Dear (=first_name=),

Welcome to HeritageCookBook.com and thank you for registering. The fun is about to begin. 

Your account has been created on our system under your email address and the password you chose when you registered. You can login any time by following this link:	

(=login_url=)

If you forget your password, click the "Forgot your Password?" link on the login page and you will be able to get a new one.'
		block.save


		block = Textblock.find_by_name 'email_added_as_contributor'
		block.text = 'Dear (=user_name=),

(=inviter_name=) has invited you to join in the fun of creating a cookbook at HeritageCookbook.com. 

(=inviter_first_name=) wrote this for you:

*(=message=)*

Since you already have an account on HeritageCookbook.com, you simply need to log in and you will see their cookbook under the "Cookbooks you can contribute to" area. You can login at:

(=login_url=)'
		block.save
		


		block = Textblock.find_by_name 'email_added_as_new_contributor'
		block.text = 'Dear (=user_name=),

(=inviter_name=) has invited you to join in the fun of creating a cookbook at HeritageCookbook.com. 

(=inviter_first_name=) wrote this for you:

*(=message=)*

To login to your account, use the following information:

Email: (=user_email=)

Password: (=user_password=)

You can login at the following address:

(=login_url=)

Once you have logged in, you can change your password to something you will remember easier by clicking on the "Edit Account" link on the top right of each page.'
		block.save
		

		block = Textblock.find_by_name 'account_confirm'
		block.text = 'We\'ve changed the way our login system works. You\'ve probably been brought to this page because you clicked on a link in an email, right?
		
Not to worry. *You don\'t need to confirm your account anymore, you just need to login.* But since you probably don\'t have a password, *"click here":/account/forgot_password to get a new password sent to you*. Just enter your email address on that page.

Sorry for the any invconvenience!'
		block.save
		
		Textblock.find_by_name('email_changed_account_email').destroy
		
		
		block = Textblock.find_by_name 'account_edit'
		block.text = 'This is where you can edit information about your account. *If you wish to change your password please "click here":/account/change_login.*'
		block.save
		
		block = Textblock.find_by_name 'account_edit_login'
		block.text = 'To change your password, please type your current password once, and then your new password twice in the spaces below.'
		block.save
		
	end

	def self.down
		block = Textblock.new
		block.name = 'email_changed_account_email'
		block.description = 'Email / Changed Account Email'
		block.text = 'Dear (=first_name=),

The email address associated with your account has been changed. To confirm your account please follow this link: 

(=confirm_url=)
'
		block.save
	end
end
