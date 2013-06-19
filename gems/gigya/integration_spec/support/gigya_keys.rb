require 'yaml'
gigya_keys = YAML.load_file(File.dirname(__FILE__) + '/gigya_keys.yml')

ENV['GIGYA_API_KEY'] = gigya_keys['api_key']
ENV['GIGYA_SECRET'] = gigya_keys['secret']