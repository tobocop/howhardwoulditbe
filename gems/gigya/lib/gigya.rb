require "gigya/version"
require "gigya/notify_login_response"
require 'gigya/http'

require 'net/http'
require 'json'

class Gigya
  attr_accessor :api_key, :secret

  def initialize(options = {})
    options.fetch(:api_key)
    options.fetch(:secret)

    self.api_key = options[:api_key]
    self.secret = options[:secret]
  end

  def notify_login(options = {})
    params = {
        siteUID: options.fetch(:site_user_id),
        newUser: true,
        format: 'json',
        userInfo: "{ firstName: \"#{options.fetch(:first_name)}\", email: \"#{options.fetch(:email)}\"}"
    }

    response = Gigya::Http.new.perform_request(api_method: 'socialize.notifyLogin', url_params: params)

    Gigya::NotifyLoginResponse.from_json(response.body)
  end

end
