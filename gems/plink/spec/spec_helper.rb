# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'

require 'plink/test_helpers/object_creation_methods'
require 'plink/test_helpers/shared_example_groups'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.use_transactional_fixtures = true

  config.include Plink::ObjectCreationMethods

  config.before(:each) do
    Plink::Config.configure do |c|
      c.image_base_url = 'http://example.com/image_base_url'
      c.card_add_url = 'http://example.com/card_add'
      c.card_change_url = 'http://example.com/card_change_url'
    end
  end

  config.after(:each) do
    Plink::Config.instance.instance_variable_set(:@configured, false)
  end

end
