require "gigya/version"
require "gigya/notify_login_response"
require 'gigya/http'

require 'net/http'
require 'json'

class Gigya
  attr_accessor :configuration

  Configuration = Struct.new(:api_key, :secret)

  def initialize(options = {})
    api_key = options.fetch(:api_key) || raise(ArgumentError, 'api_key must be specified')
    secret = options.fetch(:secret) || raise(ArgumentError, 'secret must be specified')
    self.configuration = Configuration.new(api_key, secret)
  end

  def notify_login(options = {})
    params = {
        siteUID: options.fetch(:site_user_id),
        format: 'json',
        userInfo: {firstName: options.fetch(:first_name), email: options.fetch(:email)}.to_json
    }

    params[:newUser] = true if options[:new_user]
    
    response = Gigya::Http.new(configuration, api_method: 'socialize.notifyLogin', url_params: params).perform_request

    Gigya::NotifyLoginResponse.from_json(response.body)
  end
end