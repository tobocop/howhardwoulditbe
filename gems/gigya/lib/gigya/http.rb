class Gigya
  class Http

    attr_accessor :configuration, :api_method, :url_params

    def initialize (configuration, options ={})
      self.configuration = configuration
      self.api_method = options.fetch(:api_method)
      self.url_params = options.fetch(:url_params)
    end

    def perform_request
      uri = URI('https://socialize-api.gigya.com/' + api_method)

      uri.query = URI.encode_www_form({apiKey: configuration.api_key, secret: configuration.secret}.merge(url_params))

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      http.request(request)
    end
  end
end