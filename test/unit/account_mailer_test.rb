require 'test_helper'

class AccountMailerTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper

  test "forgot password" do
    user  = users(:brian_smith)
    email = AccountMailer.forgot_password(user, "newpassword!")

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ['brian@smith.tld'], email.to
    assert_equal 'Forgot Your Password', email.subject
  end

  test "signup details" do
    user  = users(:brian_smith)
    email = AccountMailer.signup_details(user, "http://heritage-cookbook.com/signup")

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ['brian@smith.tld'], email.to
    assert_equal 'Your Heritage Cookbook Free Trial has Begun!', email.subject
  end

  test "added as contributor" do
    user    = users(:brian_smith)
    inviter = users(:john_smith)
    email   = AccountMailer.added_as_contributor(user, inviter, "http://heritage-cookbook.com/signup", "Join me bro!")

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ['brian@smith.tld'], email.to
    assert_equal 'You have been invited to help with a cookbook at HeritageCookbook.com', email.subject
    assert_match /Join me bro!/, email.html_part.to_s
    assert_match /Join me bro!/, email.text_part.to_s
  end

  test "added as new contributor" do
    user    = users(:brian_smith)
    inviter = users(:john_smith)
    email   = AccountMailer.added_as_new_contributor(user, inviter, 'custompassword', "http://heritage-cookbook.com/signup", "Join me bro!")

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ['brian@smith.tld'], email.to
    assert_equal 'You have been invited to help with a cookbook at HeritageCookbook.com', email.subject
    assert_match /Join me bro!/, email.html_part.to_s
    assert_match /Join me bro!/, email.text_part.to_s
    assert_match /custompassword/, email.html_part.to_s
    assert_match /custompassword/, email.text_part.to_s
  end

  test "order receipt" do
    user       = users(:john_smith)
    order      = orders(:john_smith_order)
    email      = AccountMailer.order_receipt(user, order, 2000)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ['john@smith.tld'], email.to
    assert_equal 'Receipt for your cookbook printing order on HeritageCookbook.com', email.subject
  end

  test "reorder receipt" do
    user       = users(:john_smith)
    order      = orders(:john_smith_order)
    email      = AccountMailer.reorder_receipt(user, order, 2000)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ['john@smith.tld'], email.to
    assert_equal 'Receipt for your cookbook printing order on HeritageCookbook.com', email.subject
  end

  [1,5,7,15,20,29].each do |num|
    test "expiry notice #{num}" do
      user  = users(:brian_smith)
      email = AccountMailer.send "expiry_notice_#{num}", user

      # Test if the email is queued
      assert_difference 'ActionMailer::Base.deliveries.count' do
        email.deliver
      end

      # Test the body of the sent email contains what we expect it to
      assert_equal ['virginie@heritagecookbook.com'], email.from
      assert_equal ['brian@smith.tld'], email.to
      assert_equal "HeritageCookbook - #{pluralize(num, 'day')} left before your free trial expires!", email.subject
    end
  end

  [1,7].each do |num|
    test "paid_account_expiry_notice_#{num}" do
      user  = users(:brian_smith)
      email = AccountMailer.send "paid_account_expiry_notice_#{num}", user

      # Test if the email is queued
      assert_difference 'ActionMailer::Base.deliveries.count' do
        email.deliver
      end

      # Test the body of the sent email contains what we expect it to
      assert_equal ['virginie@heritagecookbook.com'], email.from
      assert_equal ['brian@smith.tld'], email.to
      assert_equal "HeritageCookbook - #{pluralize(num, 'day')} left before your membership expires!", email.subject
    end
  end

  ### TODO: Those are administrative emails, move in its own section

  # test "final_pdf_uploading_started" do
  #   orders_list = []
  #   orders_list << orders(:john_smith_order)
  #   email       = AccountMailer.final_pdf_uploading_started(orders_list)

  #   # Test if the email is queued
  #   assert_difference 'ActionMailer::Base.deliveries.count' do
  #     email.deliver
  #   end

  #   # Test the body of the sent email contains what we expect it to
  #   assert_equal ['susan@heritagecookbook.com'], email.from
  #   assert_equal PDF_GENERATION_EMAIL_RECIPIENTS, email.to
  #   assert_equal "HeritageCookbook - PDF Generation Started for 1 cookbooks", email.subject
  # end

  # test "final pdf uploaded" do
  #   order = orders(:john_smith_order)
  #   email = AccountMailer.final_pdf_uploaded(order)

  #   # Test if the email is queued
  #   assert_difference 'ActionMailer::Base.deliveries.count' do
  #     email.deliver
  #   end

  #   # Test the body of the sent email contains what we expect it to
  #   assert_equal ['susan@heritagecookbook.com'], email.from
  #   assert_equal PDF_GENERATION_EMAIL_RECIPIENTS, email.to
  #   assert_equal "HeritageCookbook - Order #{order.id}-#{order.version} has been uploaded to FTP", email.subject
  # end

  # test "order_submitted" do
  #   order = orders(:john_smith_order)
  #   email = AccountMailer.order_submitted(order)

  #   # Test if the email is queued
  #   assert_difference 'ActionMailer::Base.deliveries.count' do
  #     email.deliver
  #   end

  #   # Test the body of the sent email contains what we expect it to
  #   assert_equal ['susan@heritagecookbook.com'], email.from
  #   assert_equal ORDER_PLACEMENT_EMAIL_RECIPIENTS, email.to
  #   assert_equal "HeritageCookbook - Order ##{order.id}-#{order.version} has been submited", email.subject
  # end

  # test "reorder submitted" do
  #   order = orders(:john_smith_order)
  #   email = AccountMailer.reorder_submitted(order)

  #   # Test if the email is queued
  #   assert_difference 'ActionMailer::Base.deliveries.count' do
  #     email.deliver
  #   end

  #   # Test the body of the sent email contains what we expect it to
  #   assert_equal ['susan@heritagecookbook.com'], email.from
  #   assert_equal ORDER_PLACEMENT_EMAIL_RECIPIENTS, email.to
  #   assert_equal "HeritageCookbook - Re-order ##{order.id}-#{order.version} has been submited", email.subject
  # end

  # test "hume reorder request" do
  #   order = orders(:john_smith_order)
  #   email = AccountMailer.hume_reorder_request(order)

  #   # Test if the email is queued
  #   assert_difference 'ActionMailer::Base.deliveries.count' do
  #     email.deliver
  #   end

  #   # Test the body of the sent email contains what we expect it to
  #   assert_equal ['susan@heritagecookbook.com'], email.from
  #   assert_equal REORDER_REQUEST_EMAIL_RECIPIENTS, email.to
  #   assert_equal "HeritageCookbook - Reprint of order ##{order.reorder_id}", email.subject
  # end

  # test "printer quote" do
  #   user = users(:brian_smith)
  #   email = AccountMailer.printer_quote(user, 500, 12, 12, 37000, "Soft")

  #   # Test if the email is queued
  #   assert_difference 'ActionMailer::Base.deliveries.count' do
  #     email.deliver
  #   end

  #   # Test the body of the sent email contains what we expect it to
  #   assert_equal ['susan@heritagecookbook.com'], email.from
  #   assert_equal LARGE_ORDER_QUOTE_EMAIL, email.to
  #   assert_equal "Large Quote Request from HeritageCookbook.com", email.subject
  # end
end