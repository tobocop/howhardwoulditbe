gigya_keys = YAML.load_file(Rails.root.join('config', 'gigya_keys.yml'))[Rails.env]
ENV['GIGYA_API_KEY'] = gigya_keys['gigya_api_key']
ENV['GIGYA_SECRET'] = gigya_keys['gigya_secret']

tango_keys = YAML.load_file(Rails.root.join('config', 'tango.yml'))[Rails.env]
ENV['TANGO_BASE_URL'] = tango_keys['base_url']
ENV['TANGO_USERNAME'] = tango_keys['username']
ENV['TANGO_PASSWORD'] = tango_keys['password']
