module Geoip
  class LocationLookup
    def self.by_ip(ip)
      uri = URI("https://freegeoip.net/json/#{ip}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)

      begin
        result = http.request(request)
        json_result = JSON.parse(result.body)
        generate_result(json_result)
      rescue Exception => e
        generate_result
      end
    end

  private

    def self.generate_result(options = {})
      {
        state: blank_to_nil(options['region_code']),
        city: blank_to_nil(options['city']),
        zip: blank_to_nil(options['zipcode'])
      }
    end

    def self.blank_to_nil(value)
      value.blank? ? nil : value
    end
  end
end
