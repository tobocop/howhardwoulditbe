# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'plink_admin/test_helpers/object_creation_methods'
require 'plink/test_helpers/object_creation_methods'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("../support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Plink::ObjectCreationMethods
  config.include PlinkAdmin::ObjectCreationMethods
  config.include PlinkAdmin::FeatureSpecHelpers, type: :feature
  config.include EngineControllerRoutesFix, :type => :controller
  config.include Devise::TestHelpers, :type => :controller

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

PlinkAdmin.impersonation_redirect_url = '/'

PlinkAdmin.sign_in_user = ->(user_id, session) do
  session[:current_user_id] = user_id
end