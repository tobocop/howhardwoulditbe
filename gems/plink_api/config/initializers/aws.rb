
aws_keys = YAML.load_file(Rails.root.join('config', 'aws.yml'))[Rails.env]

AWS.config(
  :access_key_id => aws_keys['access_key_id'],
  :secret_access_key => aws_keys['secret_access_key']
)
