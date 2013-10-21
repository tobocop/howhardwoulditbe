require 'net/http'

module Lyris
  class Http
    attr_accessor :activity, :additional_xml, :config, :email, :type

    def initialize(config, type, activity, options={})
      @activity = activity
      @additional_xml = options[:additional_xml]
      @config = config
      @email = options[:email]
      @type = type
    end

    def perform_request
      uri = URI('https://secure.elabs10.com/API/mailing_list.html')
      uri.query = URI.encode_www_form({type: type, activity: activity})

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(input: payload_data)

      http.request(request)
    end

  private

    def payload_data
      %Q{<DATASET>
        <SITE_ID>#{config.site_id}</SITE_ID>
        <DATA type="extra" id="password">#{config.password}</DATA>
        <MLID>#{config.mailing_list_id}</MLID>
        <DATA type="email">#{email}</DATA>
        #{additional_xml}
      </DATASET>}
    end
  end
end
