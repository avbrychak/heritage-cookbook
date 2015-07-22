CookbookHeritage::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Use Gmail SMTP server in development
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => 'heritage.cookbook.testing@gmail.com',
    :password             => 'ESSGYtHC',
    :authentication       => 'plain',
    :enable_starttls_auto => true  
  }

  config.after_initialize do

    # Paypall Sandbox account
    ActiveMerchant::Billing::Base.mode = :test
    paypal_options = {
      :login => "garnier.etienne-facilitator_api1.gmail.com",
      :password => "1370864447",
      :signature => "An5ns1Kso7MWUdW4ErQKJJJ4qi4-AVCZCmkDz6vqHx0geBzBjGOc8npO"
    }
    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)

    # Beanstream API id
    ::BEANSTREAM_MERCHANT_ID = 293210000

    # Printing FTP access
    ::HUME_FTP_HOSTNAME      = 'localhost'
    ::HUME_FTP_USERNAME      = 'anonymous'
    ::HUME_FTP_PASSWORD      = nil
    ::HUME_FTP_REMOTE_FOLDER = '/test'

    # Website URL
    ::WORDPRESS_URL = "http://localhost"

    # Administrative password
    ::ADMIN_PASS = "407c6798fe20fd5d75de4a233c156cc0fce510e3" # 'admin_password'

    # Wordpress email to receive blog entry
    ::WORDPRESS_API_EMAIL = 'heritage.cookbook.testing@gmail.com'
  end
end
