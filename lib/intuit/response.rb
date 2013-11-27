module Intuit
  class Response
    attr_accessor :raw_response

    def initialize(intuit_response)
      @raw_response = intuit_response
    end

    def parse
      if successful?(raw_response)
        accounts = accounts_from_response(raw_response)

        {error: false, value: accounts, aggr_status_codes: parse_status_codes(accounts)}
      elsif mfa?(raw_response)
        challenge_session_id = raw_response[:challenge_session_id]
        challenge_node_id = raw_response[:challenge_node_id]
        value = {questions: mfa_questions(raw_response), challenge_session_id: challenge_session_id, challenge_node_id: challenge_node_id}

        {error: false, mfa: true, value: value}
      else
        {error: true, value: error_message(raw_response)}
      end
    end

  private

    def parse_status_codes(accounts)
      accounts.map {|account| account[:aggr_status_code].to_i }.uniq
    end

    def successful?(intuit_response)
      intuit_response[:status_code] == '200' || intuit_response[:status_code] == '201'
    end

    def mfa?(intuit_response)
      intuit_response[:status_code] == '401'
    end

    def accounts_from_response(intuit_response)
      accounts = Intuit::AccountsPresenter.new(intuit_response[:result][:account_list]).accounts
      accounts.map{|account| account.to_hash}
    end

    def mfa_questions(intuit_response)
      intuit_response[:result][:challenges][:challenge]
    end

    def error_message(intuit_response)
      intuit_response[:result][:status][:error_info][:error_message]
    end
  end
end
