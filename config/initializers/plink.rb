keys = YAML.load_file(Rails.root.join('config', 'plink.yml'))[Rails.env]

Plink::Config.configure do |config|
  config.image_base_url = keys['image_base_url']
  config.mobile_registration_url = keys['mobile_registration_url']
end
