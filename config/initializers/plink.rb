keys = YAML.load_file(Rails.root.join('config', 'plink.yml'))[Rails.env]

Plink::Config.configure do |config|
  config.image_base_url = keys['image_base_url']
  config.card_add_url = keys['card_add_url']
  config.card_change_url = keys['card_change_url']
end