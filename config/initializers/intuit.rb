require Rails.root.join('lib/intuit/intuit.rb')

intuit_keys = YAML.load_file(Rails.root.join('config', 'intuit.yml'))[Rails.env]

Aggcat.configure do |config|
  config.issuer_id = intuit_keys['issuer_id'] #'your issuer id'
  config.consumer_key = intuit_keys['consumer_key'] # 'your consumer key'
  config.consumer_secret = intuit_keys['consumer_secret'] # 'your consumer secret'
  config.certificate_path = intuit_keys['certificate_path'] #'/path/to/your/certificate/key'
end

Intuit.logger = ActiveSupport::BufferedLogger.new('log/intuit.log')
