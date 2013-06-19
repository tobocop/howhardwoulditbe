Gigya::Config.configure do |config|
  config.api_key = ENV['GIGYA_API_KEY']
  config.secret = ENV['GIGYA_SECRET']
end
