# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'rspec/retry'
require 'plink/test_helpers/object_creation_methods'
require 'plink/test_helpers/shared_example_groups'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

SharedRSpecConfig.setup(RSpec.configuration)

Capybara.app_host = "http://plink.test:58891"
Capybara.server_port = 58891
Capybara.javascript_driver = :webkit

if ENV['CI']
  RSpec.configuration.before(:each, type: :feature) do
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end
end
