require 'gigya'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/object/blank'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/../integration_spec/support/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.before(:each) do
    Gigya::Config.configure do |config|
      config.api_key = ENV['GIGYA_API_KEY']
      config.secret = ENV['GIGYA_SECRET']
    end
  end

  config.after(:each) do
    Gigya::Config.instance.instance_variable_set(:@configured, false)
  end
end
