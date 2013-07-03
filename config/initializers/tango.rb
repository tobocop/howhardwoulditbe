Tango::Config.configure do |config|
  config.base_url = ENV['TANGO_BASE_URL']
  config.username = ENV['TANGO_USERNAME']
  config.password = ENV['TANGO_PASSWORD']
end
