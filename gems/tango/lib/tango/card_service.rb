module Tango
  class CardService

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def purchase(params = {})
      http_response = Http::Request.new(config).post('/Version2/PurchaseCard', request_body(params))
      PurchaseCardResponse.from_json(http_response.body)
    end

    private

    def request_body(params)
      {
          username: config.username,
          password: config.password,
          cardSku: params.fetch(:card_sku),
          cardValue: params.fetch(:card_value).to_i,
          tcSend: params.fetch(:tango_sends_email),
          recipientName: params.fetch(:recipient_name),
          recipientEmail: params.fetch(:recipient_email),
          giftMessage: params.fetch(:gift_message),
          giftFrom: params.fetch(:gift_from)
      }
    end
  end
end
