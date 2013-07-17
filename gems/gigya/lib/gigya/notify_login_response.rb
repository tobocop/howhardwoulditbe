class Gigya
  class NotifyLoginResponse < GigyaResponse
    attr_accessor :status_code, :cookie_name, :cookie_value, :cookie_domain, :error_code

    def initialize(options = {})
      self.status_code = options.fetch(:status_code)
      self.error_code = options[:error_code] || 0
      self.cookie_name = options[:cookie_name]
      self.cookie_value = options[:cookie_value]
      self.cookie_domain = options[:cookie_domain]
    end

    def self.from_json(json)
      json_params = parse_json(json)
      new({
        status_code: json_params['statusCode'],
        cookie_name: json_params['cookieName'],
        cookie_value: json_params['cookieValue'],
        cookie_domain: json_params['cookieDomain'],
        error_code: json_params['errorCode']
      })
    end

    def cookie_path
      '/'
    end
  end
end