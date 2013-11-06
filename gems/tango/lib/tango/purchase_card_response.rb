module Tango
  class PurchaseCardResponse

    attr_reader :card_number, :card_token, :raw_response, :reference_order_id, :response_type

    def initialize(attrs)
      @response_type = attrs.fetch(:response_type)
      @reference_order_id = attrs.fetch(:reference_order_id)
      @card_token = attrs.fetch(:card_token)
      @card_number = attrs.fetch(:card_number)
      @raw_response = attrs[:raw_response]
    end

    def successful?
      true
    end

    def self.from_json(json)
      response = JSON.parse(json)

      if response.has_key?('responseType') && response['responseType'] == 'SUCCESS'
        new(
          response_type: response['responseType'],
          reference_order_id: response['response']['referenceOrderId'],
          card_token: response['response']['cardToken'],
          card_number: response['response']['cardNumber'],
          raw_response: response
        )
      elsif response.has_key?('responseType') && response['responseType'] != 'SUCCESS'
        error = case
                  when response['response'].has_key?('errorCode')
                    response['response']['errorCode']
                  when response['response'].has_key?('invalid')
                    response['response']['invalid']['body']
                  else
                    response['response']
                end

        FailureResponse.new(
          response_type: response['responseType'],
          error_message: error,
          raw_response: response
        )
      else
        raise Tango::PurchaseCardResponse::OtherError, response.to_s
      end
    end

    class OtherError < StandardError;
    end

    class FailureResponse

      attr_reader :response_type, :error_message, :raw_response

      def initialize(attrs)
        @response_type = attrs.fetch(:response_type)
        @error_message = attrs[:error_message]
        @raw_response = attrs[:raw_response]
      end

      def successful?
        false
      end
    end
  end
end
