# external requires
require 'json'
require 'net/http'
require 'singleton'
require 'base64'
require 'openssl'

# internal requires
require 'gigya/config'
require 'gigya/http'
require 'gigya/notify_login_response'
require 'gigya/signature'
require 'gigya/user'
require 'gigya/version'

class Gigya

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def notify_login(options = {})
    params = {
        siteUID: options.fetch(:site_user_id),
        format: 'json',
        userInfo: {firstName: options.fetch(:first_name), email: options.fetch(:email)}.to_json
    }

    params[:newUser] = true if options[:new_user]

    response = Gigya::Http.new(config, api_method: 'socialize.notifyLogin', url_params: params).perform_request

    Gigya::NotifyLoginResponse.from_json(response.body)
  end
end