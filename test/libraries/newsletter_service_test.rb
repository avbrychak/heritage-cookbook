require 'test_helper'

class NewsletterServiceTest < ActiveSupport::TestCase

  setup do
    NewsletterService::MAILING_LIST = "test"
    Mailjet.configure do |config|
      config.api_key = NewsletterService::MAILJET_KEY
      config.secret_key = NewsletterService::MAILJET_SECRET
      config.default_from = NewsletterService::FROM_EMAIL
    end
    @list = Mailjet::List.create(label: 'Testing mailing list', name: "test")
    @newsletter = NewsletterService.new
  end

  teardown do
    @list.delete
  end

  test "List all user with a subscription to the newletter" do
    assert_equal Array,  @newsletter.list.class
  end

  test "Add an email to the mailing list" do
    assert_difference "@newsletter.list.length", 1 do
      assert @newsletter.add "testing@gmail.com"
    end
  end

  test "Remove an email from the mailing list" do
    @newsletter.add "testing@gmail.com"
    assert_difference "@newsletter.list.length", -1 do
      assert @newsletter.remove "testing@gmail.com"
    end
  end

  test "Ask if an email is present in the mailing list" do
    assert !@newsletter.subscribed?("testing_presence@gmail.com")
    @newsletter.add "testing_presence@gmail.com"
    assert @newsletter.subscribed?("testing_presence@gmail.com")
  end
end