module Intuit
  class Response
    attr_accessor :raw_response

    def initialize(intuit_response)
      @raw_response = intuit_response
    end

    def parse
      if successful?
        {error: false, value: accounts, aggr_status_codes: parse_status_codes(accounts)}
      elsif mfa?
        challenge_session_id = raw_response[:challenge_session_id]
        challenge_node_id = raw_response[:challenge_node_id]
        value = {questions: mfa_questions, challenge_session_id: challenge_session_id, challenge_node_id: challenge_node_id}

        {error: false, mfa: true, value: value}
      else
        {error: true, value: error_message}
      end
    end

    def accounts
      intuit_account_presenters = Intuit::AccountsPresenter.new(raw_response[:result][:account_list]).accounts
      intuit_account_presenters.map{|intuit_account_presenter| intuit_account_presenter.to_hash}
    end

    def accounts?
      raw_response[:result].has_key?(:account_list)
    end

    def login_id
      accounts.first[:login_id]
    end

    def aggregation_error?
      parse_status_codes(accounts) != [0]
    end

    def first_error_status_code
      parse_status_codes(accounts).find {|status_code| status_code != 0}
    end

  private

    def parse_status_codes(accounts)
      accounts.map {|account| account[:aggr_status_code].to_i }.uniq
    end

    def successful?
      raw_response[:status_code] == '200' || raw_response[:status_code] == '201'
    end

    def mfa?
      raw_response[:status_code] == '401'
    end

    def mfa_questions
      raw_response[:result][:challenges][:challenge]
    end

    def error_message
      raw_response[:result][:status][:error_info][:error_message]
    end
  end
end
