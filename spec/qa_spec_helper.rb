# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'plink/test_helpers/object_creation_methods'
require 'plink/test_helpers/fake_services/fake_offer_service'
require 'plink/test_helpers/shared_example_groups'
require 'plink_admin/test_helpers/object_creation_methods'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

SharedRSpecConfig.setup(RSpec.configuration)

RSpec.configuration.before(:each, type: :feature) do
  page.driver.browser.manage.window.resize_to(1000, 1000)
end

Capybara.app_host = "http://plink.test:58891"
Capybara.server_port = 58891
