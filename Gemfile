source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mysql2'
gem 'paperclip'
gem 'aws-sdk', '1.19.0'
gem 'haml-rails'
gem 'prawn', '~> 1.0.0.rc2'
gem 'fastimage'
gem 'delayed_job_active_record'
gem 'activemerchant'
gem 'mailjet', '0.0.5'
gem "ransack" 
gem 'will_paginate', '~> 3.0'
gem 'active_shipping', '0.11.2'

gem 'unicorn'

# Process memory turn crazy over time, 
# don't know if its memory bloats or leaks
# See config.ru for options
gem 'unicorn-worker-killer'

gem 'daemons'

# Help to find memory bloat
gem "oink"

# New Relic monitoring
# gem 'newrelic_rpm'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'sqlite3'
  gem 'debugger'
end

group :production do
  gem 'pg'
end
