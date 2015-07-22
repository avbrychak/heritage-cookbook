require 'mailjet'

class NewsletterService

  MAILJET_KEY = "5fa8fd813cd84ab272f5657333ffab2f"
  MAILJET_SECRET = "d2057dfc27bb894775eeed5f5785c358"
  MAILING_LIST = "newsletter"
  FROM_EMAIL = "newsletter@heritagecookbook.com"

  def initialize
    Mailjet.configure do |config|
      config.api_key = MAILJET_KEY
      config.secret_key = MAILJET_SECRET
      config.default_from = FROM_EMAIL
    end
    Mailjet::List.all(limit: 10, start: 0, orderby: 'id ASC').each do |mailing_list|
      @mailing_list = mailing_list if mailing_list.name == MAILING_LIST
    end
    raise "Mailing list not found" if !@mailing_list
  end

  # List all user having subscribed to the `MAILING_LIST` mailing list
  def list
    @mailing_list.contacts(limit: 10000).map{|contact| contact.email}
  end

  # Add an email to the mailing list
  # Return true if the email has been added, false if not
  # Return false if the email has already subscribed to the mailing list
  def add(email)
    eval_response = @mailing_list.add_contacts(email, force: true)
  end

  # Remove an email from the mailing list
  # Return true if the email is no more in the mailing list
  def remove(email)
    @mailing_list.remove_contacts(email, force:true)
  end

  # Return a boolean telling if an email has subscribed to the mailing list
  def subscribed?(email)
    list.include? email
  end

  private

  # Return a boolean, true if the action has been 
  # correctly executed, false otherwise
  def eval_response(response)
    return (response == "OK")
  end
end