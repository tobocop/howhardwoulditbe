class Gigya
  class UserInfoResponse < GigyaResponse
    attr_accessor :error_code, :json, :status_code

    def initialize(attributes = {})
      self.error_code = attributes[:error_code] || 0
      self.json = attributes.fetch(:raw_json)
      self.status_code = attributes.fetch(:status_code)
    end

    def self.from_json(json)
      json_params = parse_json(json)
      new({
        error_code: json_params['errorCode'],
        raw_json: json,
        status_code: json_params['statusCode']
      })
    end
  end
end
