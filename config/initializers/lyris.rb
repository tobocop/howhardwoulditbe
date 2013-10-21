lyris_yml = YAML.load_file(Rails.root.join('config', 'lyris.yml'))[Rails.env]

Lyris::Config.configure do |config|
  config.site_id = lyris_yml['site_id']
  config.password = lyris_yml['password']
  config.mailing_list_id = lyris_yml['mailing_list_id']
end
