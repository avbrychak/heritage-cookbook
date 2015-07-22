require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Need to export some part in CSV
require 'csv'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  # Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  Bundler.require(:default, :assets, Rails.env)
end

# Disable deprecation warning
ActiveSupport::Deprecation.silenced = true

module CookbookHeritage
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib #{config.root}/app/models/concerns) # To support multi-thread

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Configure action view to use 'prototype' instead of library
    config.action_view.javascript_expansions = { :prototype => %w(prototype effects dragdrop controls rails application) }

    config.after_initialize do

      # Where PDF documents are stored
      ::PDF_IMAGES_PATH = Rails.root.join "public", "final_pdfs"
      ::PDF_PREVIEW_FOLDER = Rails.root.join "public", "pdf_previews"

      # Administrator allowed emails
      ::ALLOWED_USERS = ['testing@yopmail.com']

      # Administrative emails recipiants
      ::CONTACT_EMAIL = 'virginie@heritagecookbook.com'
      ::HUME_CONTACT_EMAIL = 'kourtney@humemediainc.com'
      ::PDF_GENERATION_EMAIL_RECIPIENTS   = ['pdf-generation@heritagecookbook.com']
      ::ORDER_PLACEMENT_EMAIL_RECIPIENTS  = ['orders@heritagecookbook.com']
      ::REORDER_REQUEST_EMAIL_RECIPIENTS  = ['orders@heritagecookbook.com']
      ::ACCOUNT_UPGRADED_EMAIL_RECIPIENTS = ['virginie@heritagecookbook.com']
      ::LARGE_ORDER_QUOTE_EMAIL           = ['printer@heritagecookbook.com']

      # Plan ID assigned to contributors
      ::CONTRIBUTOR_PLAN_ID = 5

      # Special plan used to recover cookbooks
      ::COOKBOOK_RECOVERY_PLAN_ID = 7

      # User session expiration time (in seconds)
      ::MAX_SESSION_TIME = 60 * 60 * 2

      # Default binding for unbinded cookbook (re-order)
      ::DEFAULT_BINDING = "Plastic Coil"
    end
  end
end