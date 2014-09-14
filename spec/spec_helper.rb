require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'shoulda/matchers'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Features::SessionHelpers, type: :feature
  config.include Devise::TestHelpers, :type => :controller
  config.include Controllers::SessionHelpers, :type => :controller
  config.include FactoryGirl::Syntax::Methods
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.order = 'random'
  config.use_transactional_fixtures = false
end

Capybara.javascript_driver = :webkit
WebMock.disable_net_connect!(allow_localhost: true)
