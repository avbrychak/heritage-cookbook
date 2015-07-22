# Send all mail to heritage.cookbook.testing@gmail.com in Staging and Development.
if Rails.env.development? || Rails.env == "dev_amazon"
  class OverrideMailRecipient
    def self.delivering_email(mail)
      mail.to = 'heritage.cookbook.testing@gmail.com'
    end
  end
  ActionMailer::Base.register_interceptor(OverrideMailRecipient)
end
