require 'test_helper'

class AdministrativeMailerTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper

  test "final_pdf_uploading_started" do
    orders_list = []
    orders_list << orders(:john_smith_order)
    email       = AdministrativeMailer.final_pdf_uploading_started(orders_list)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal PDF_GENERATION_EMAIL_RECIPIENTS, email.to
    assert_equal "HeritageCookbook - PDF Generation Started for 1 cookbooks", email.subject
  end

  test "final pdf uploaded" do
    order = orders(:john_smith_order)
    email = AdministrativeMailer.final_pdf_uploaded(order)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal PDF_GENERATION_EMAIL_RECIPIENTS, email.to
    assert_equal "HeritageCookbook - Order #{order.id}-#{order.version} has been uploaded to FTP", email.subject
  end

  test "order_submitted" do
    order = orders(:john_smith_order)
    email = AdministrativeMailer.order_submitted(order)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ORDER_PLACEMENT_EMAIL_RECIPIENTS, email.to
    assert_equal "HeritageCookbook - Order ##{order.id}-#{order.version} has been submited", email.subject
  end

  test "reorder submitted" do
    order = orders(:john_smith_order)
    email = AdministrativeMailer.reorder_submitted(order)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ORDER_PLACEMENT_EMAIL_RECIPIENTS, email.to
    assert_equal "HeritageCookbook - Re-order ##{order.id}-#{order.version} has been submited", email.subject
  end

  test "hume reorder request" do
    order = orders(:john_smith_order_2)
    email = AdministrativeMailer.hume_reorder_request(order)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal REORDER_REQUEST_EMAIL_RECIPIENTS, email.to
    assert_equal "HeritageCookbook - Reprint of order ##{order.reorder_id}", email.subject
  end

  test "printer quote" do
    user = users(:brian_smith)
    email = AdministrativeMailer.printer_quote(user, 500, 12, 12, 37000, "Soft")

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal LARGE_ORDER_QUOTE_EMAIL, email.to
    assert_equal "Large Quote Request from HeritageCookbook.com", email.subject
  end  

  test "account upgraded" do
    user       = users(:brian_smith)
    email      = AdministrativeMailer.account_upgraded(user)

    # Test if the email is queued
    assert_difference 'ActionMailer::Base.deliveries.count' do
      email.deliver
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['virginie@heritagecookbook.com'], email.from
    assert_equal ACCOUNT_UPGRADED_EMAIL_RECIPIENTS, email.to
    assert_equal "HeritageCookbook - Account upgraded for #{user.email}", email.subject
  end
end