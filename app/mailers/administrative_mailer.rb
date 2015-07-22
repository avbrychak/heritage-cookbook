# Manage administrative emails for operators or printing service
class AdministrativeMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper

  # Notification email for operators (start generate orderered cookbooks PDF file)
  def final_pdf_uploading_started(orders)
    @orders = orders
    mail to: PDF_GENERATION_EMAIL_RECIPIENTS,
      from: CONTACT_EMAIL,
      subject: "HeritageCookbook - PDF Generation Started for #{orders.size} cookbooks"
  end

  # Notification email for operators (an orderered cookbook file has been submitted to the printing FTP server)
  def final_pdf_uploaded(order)
    @order    = order
    @filename = order.filename
    mail to: PDF_GENERATION_EMAIL_RECIPIENTS,
      from: CONTACT_EMAIL,
      subject: "HeritageCookbook - Order #{order.id}-#{order.version} has been uploaded to FTP"
  end

  # Notification email for operators (an order for a cookbook has been paid)
  def order_submitted(order)
    @order = order
    mail to: ORDER_PLACEMENT_EMAIL_RECIPIENTS,
      from: CONTACT_EMAIL,
      subject: "HeritageCookbook - Order ##{order.id}-#{order.version} has been submited"
  end

  # Notification email for operators (a new re-order for an already uploaded cookbook has been paid)
  def reorder_submitted(order)
    @order = order
    mail to: ORDER_PLACEMENT_EMAIL_RECIPIENTS,
      from: CONTACT_EMAIL,
      subject: "HeritageCookbook - Re-order ##{order.id}-#{order.version} has been submited"
  end

  # Notification email for printing service telling them a cookbook as been re-ordered
  def hume_reorder_request(order)
    @order = order
    mail to: REORDER_REQUEST_EMAIL_RECIPIENTS,
      from: CONTACT_EMAIL,
      subject: "HeritageCookbook - Reprint of order ##{order.reorder_id}"
  end

  # Notification email for operators (an user has upgraded its account)
  def account_upgraded(user)
    @user = user
    mail to: ACCOUNT_UPGRADED_EMAIL_RECIPIENTS,
      from: CONTACT_EMAIL,
      subject: "HeritageCookbook - Account upgraded for #{user.email}"
  end

  # Notification for printing service telling them details about a large order request
  def printer_quote(user, num_cookbooks, num_bw_pages, num_color_pages, zip_code, book_binding)
    @user            = user
    @num_cookbooks   = num_cookbooks
    @num_bw_pages    = num_bw_pages
    @num_color_pages = num_color_pages
    @zip_code        = zip_code
    @book_binding    = book_binding

    mail to: LARGE_ORDER_QUOTE_EMAIL,
      from: CONTACT_EMAIL,
      subject: "Large Quote Request from HeritageCookbook.com"
  end
end