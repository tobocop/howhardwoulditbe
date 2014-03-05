module Intuit
  class TransactionResponse
    attr_reader :raw_response

    def initialize(raw_response)
      @raw_response = raw_response
    end

    def to_h
      transactions? ? {error: false, transactions: true} : {error: true, value: "Account has no transactions."}
    end

  private

    def transactions?
      raw_response[:result][:transaction_list].has_key?(:credit_card_transaction) ||
        raw_response[:result][:transaction_list].has_key?(:banking_transaction)
    end
  end
end
