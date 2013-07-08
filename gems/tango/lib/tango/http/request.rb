module Tango
  module Http
    class Request

      attr_reader :config

      def initialize(config)
        @config = config
      end

      def post(path, body)
        connection = Faraday.new(url: config.base_url)
        connection.post do |req|
          req.url path
          req.body = body.to_json
        end
      end
    end
  end
end
