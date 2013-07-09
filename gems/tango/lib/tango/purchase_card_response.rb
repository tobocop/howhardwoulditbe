module Tango
  class PurchaseCardResponse

    attr_reader :response_type, :reference_order_id, :card_token, :card_number

    def initialize(attrs)
      @response_type = attrs.fetch(:response_type)
      @reference_order_id = attrs.fetch(:reference_order_id)
      @card_token = attrs.fetch(:card_token)
      @card_number = attrs.fetch(:card_number)
    end

    def successful?
      true
    end

    def self.from_json(json)
      response = JSON.parse(json)

      if response['responseType'] == 'SUCCESS'

        new(
            response_type: response['responseType'],
            reference_order_id: response['response']['referenceOrderId'],
            card_token: response['response']['cardToken'],
            card_number: response['response']['cardNumber']
        )
      else
        FailureResponse.new(response_type: response['responseType'], error_message: response['response']['invalid']['body'])
      end
    end

    class FailureResponse

      attr_reader :response_type, :error_message

      def initialize(attrs)
        @response_type = attrs.fetch(:response_type)
        @error_message = attrs.fetch(:error_message)
      end

      def successful?
        false
      end
    end
  end
end