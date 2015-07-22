CookbookHeritage::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.after_initialize do
    # Website URL
    ::WORDPRESS_URL = "http://localhost:3000"

    # Active merchant configuration
    ActiveMerchant::Billing::Base.mode = :test
    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalBogusGateway.new

    # Administrative password
    ::ADMIN_PASS = "407c6798fe20fd5d75de4a233c156cc0fce510e3" # 'admin_password'

    # Beanstream API id
    ::BEANSTREAM_MERCHANT_ID = 293210000

    # Wordpress email to receive blog entry
    ::WORDPRESS_API_EMAIL = 'heritage.cookbook.testing@gmail.com'
  end
end
