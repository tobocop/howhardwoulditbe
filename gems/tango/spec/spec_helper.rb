require 'tango'
require 'artifice'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before(:each) do
    Tango::Config.configure do |c|
      c.base_url = 'https://int.tangocard.com'
      c.username = 'third_party_int@tangocard.com'
      c.password = 'integrateme'
    end
  end

  config.after(:each) do
    Tango::Config.instance.instance_variable_set(:@configured, false)
  end
end
