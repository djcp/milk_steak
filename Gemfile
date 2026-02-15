source 'https://rubygems.org'

gem 'rails', '~> 8.0.0'

# Required for Ruby 3.4 compatibility
gem 'mutex_m'
gem 'bigdecimal'
gem 'drb'
gem 'base64'

gem 'bourbon'
gem 'bitters'
gem 'neat'
gem 'email_validator'
gem 'flutie'
gem 'high_voltage'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'image_processing', '~> 1.2'
gem 'active_storage_validations'
gem 'pg', '~> 1.1'
gem 'recipient_interceptor'
gem 'dartsass-rails'
gem 'simple_form'
gem 'terser'
gem 'puma'
gem 'devise', '~> 4.9'
gem 'acts_as_list'
gem 'acts-as-taggable-on', '~> 13.0'
gem 'will_paginate'
gem 'sprockets-rails'
gem 'redcarpet'
gem 'rails-controller-testing'
gem 'responders'
gem 'aws-sdk-s3', require: false

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'bundler-audit'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'brakeman', require: false
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem 'launchy'
  gem 'shoulda-matchers', '~> 5.0', require: false
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end

group :production do
  gem 'rack-timeout'
  gem 'newrelic_rpm'
end
