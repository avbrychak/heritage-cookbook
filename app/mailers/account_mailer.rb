# Manage emails related to user accounts and orders
class AccountMailer < ActionMailer::Base
  layout 'email'

  include ActionView::Helpers::TextHelper

  # Send an user its new password
  def forgot_password(user, password)
    @first_name = user.first_name
    @password = password
    mail to: user.email,
      from: CONTACT_EMAIL,
      subject: 'Forgot Your Password'
  end

  # Send signup detail to user
  def signup_details(user, login_url)
    @first_name = user.first_name
    @login_url = login_url
    @email = user.email
    mail to: user.email,
      from: CONTACT_EMAIL,
      subject: 'Your Heritage Cookbook Free Trial has Begun!'
  end

  # Send a notification to member added as contributor
  def added_as_contributor(user, inviter, specified_login_url, message=nil)
    @user = user
    @inviter = inviter
    @login_url = specified_login_url
    @message = message
    mail to: @user.email,
      from: CONTACT_EMAIL,
      subject: 'You have been invited to help with a cookbook at HeritageCookbook.com'
  end

  # Send a notification to people (= non members) added as contributor
  def added_as_new_contributor(user, inviter, password, specified_login_url, message=nil)
    @user = user
    @inviter = inviter
    @login_url = specified_login_url
    @password = password
    @message = message
    mail to: user.email,
      from: CONTACT_EMAIL,
      subject: 'You have been invited to help with a cookbook at HeritageCookbook.com'
  end

  # Send an order receipt to an user
  def order_receipt(user, order, charged)
    @user_name = user.name
    @order = order
    @charged = charged
    mail to: user.email,
      from: CONTACT_EMAIL,
      subject: 'Receipt for your cookbook printing order on HeritageCookbook.com'
  end

  # Send a re-order receipt to an user
  def reorder_receipt(user, order, charged)
    @user_name = user.name
    @order = order
    @charged = charged
    mail to: user.email,
      from: CONTACT_EMAIL,
      subject: 'Receipt for your cookbook printing order on HeritageCookbook.com'
  end

  # Send user expiry notices for users in free trials
  [1,5,7,15,20,29].each do |num|
    define_method "expiry_notice_#{num}" do |user|
      @user_name = user.name
      mail to: user.email,
        from: CONTACT_EMAIL,
        subject: "HeritageCookbook - #{pluralize(num, 'day')} left before your free trial expires!"
    end
  end

  # Send user expiry notices for users with paid accounts
  [1,7].each do |num|
    define_method "paid_account_expiry_notice_#{num}" do |user|
      @user_name = user.name
      mail to: user.email,
        from: CONTACT_EMAIL,
        subject: "HeritageCookbook - #{pluralize(num, 'day')} left before your membership expires!"
    end
  end
end