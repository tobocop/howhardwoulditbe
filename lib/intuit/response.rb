module Intuit
  class Response
    attr_accessor :raw_response

    def initialize(intuit_response)
      @raw_response = intuit_response
    end

    def parse
      response = {error: false}
      if successful?
        if accounts?
          response.merge!(value: accounts, aggr_status_codes: parse_status_codes(accounts))
        elsif transaction_response?
          response = Intuit::TransactionResponse.new(raw_response).to_h
        end
      elsif mfa?
        response.merge!(mfa: true, value: questions_and_challenge_ids)
      else
        response = {error: true, value: error_message}
      end

      response
    end

    def accounts
      intuit_account_presenters = Intuit::AccountsPresenter.new(raw_response[:result][:account_list]).accounts
      intuit_account_presenters.map{|intuit_account_presenter| intuit_account_presenter.to_hash}
    end

    def accounts?
      raw_response[:result].present? && raw_response[:result].has_key?(:account_list)
    end

    def login_id
      accounts.first[:login_id]
    end

    def aggregation_error?
      accounts? && parse_status_codes(accounts).first != 0
    end

    def first_error_status_code
      parse_status_codes(accounts).find {|status_code| status_code != 0}
    end

  private

    def parse_status_codes(accounts)
      accounts.map {|account| account[:aggr_status_code].to_i }.uniq.sort
    end

    def successful?
      raw_response[:status_code] == '200' || raw_response[:status_code] == '201'
    end

    def transaction_response?
      raw_response[:result].present? && raw_response[:result].has_key?(:transaction_list)
    end

    def mfa?
      raw_response[:status_code] == '401'
    end

    def questions_and_challenge_ids
      {
        questions: raw_response[:result][:challenges][:challenge],
        challenge_session_id: raw_response[:challenge_session_id],
        challenge_node_id: raw_response[:challenge_node_id]
      }
    end

    def error_message
      if hash_has_nested_key?(raw_response, [:result, :status, :error_info, :error_message])
        raw_response[:result][:status][:error_info][:error_message]
      else
        'We could not determine the nature of the error.'
      end
    end

    def hash_has_nested_key?(hash, keys)
      return true if keys == []
      hash.has_key?(keys.first) ? hash_has_nested_key?(hash[keys.shift], keys) : false
    end
  end
end
