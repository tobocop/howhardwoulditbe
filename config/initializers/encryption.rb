environment_salt = YAML.load_file(Rails.root.join('config', 'salt.yml'))[Rails.env]
secret = Digest::SHA1.hexdigest(environment_salt['salt'])
ENCRYPTION = ActiveSupport::MessageEncryptor.new(secret)
