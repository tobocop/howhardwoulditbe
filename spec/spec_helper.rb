# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'rspec/retry'
require 'plink/test_helpers/object_creation_methods'
require 'plink/test_helpers/shared_example_groups'
require 'plink_admin/test_helpers/object_creation_methods'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.verbose_retry = true

  config.include(FeatureSpecHelper, type: :feature)
  config.include(ControllerSpecHelper, type: :controller)
  config.include(UserActions, type: :feature)
  config.include(Plink::ObjectCreationMethods)
  config.include(PlinkAdmin::ObjectCreationMethods)

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each, type: :feature) do
    delete_users_from_gigya
  end
end

Capybara.app_host = "http://plink.test:58891"
Capybara.server_port = 58891

if ENV['CI']
  RSpec.configuration.before(:each, type: :feature, js: true) do
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  Capybara.default_wait_time = 30
else
  Capybara.default_wait_time = 10
  Capybara.javascript_driver = :webkit
end

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

module Exceptional ; class Catcher ; def self.handle(exception) ; end ; end ; end
