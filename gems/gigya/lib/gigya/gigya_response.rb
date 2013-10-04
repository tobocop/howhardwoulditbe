class Gigya
  class GigyaResponse
    attr_accessor :status_code, :error_code

    def initialize(options = {})
      self.status_code = options.fetch(:status_code)
      self.error_code = options[:error_code] || 0
    end

    def self.from_json(json)
      json_params = parse_json(json)
      new({
        status_code: json_params['statusCode'],
        error_code: json_params['errorCode']
      })
    end

    def self.parse_json(json)
      JSON.parse(json)
    end

    def successful?
      (error_code == 0) && (status_code == 200)
    end
  end
end
