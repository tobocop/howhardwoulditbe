class Gigya
  class NotifyLoginResponse
    attr_accessor :status_code, :cookie_name, :cookie_value, :cookie_domain, :error_code

    def initialize(options = {})
      self.status_code = options.fetch(:status_code)
      self.cookie_name = options[:cookie_name]
      self.cookie_value = options[:cookie_value]
      self.cookie_domain = options[:cookie_domain]
      self.error_code = options[:error_code] || 0
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

    def self.parse_json(json)
      JSON.parse(json)
    end

    def cookie_path
      '/'
    end

    def successful?
      (error_code == 0) && (status_code == 200)
    end

  end
end