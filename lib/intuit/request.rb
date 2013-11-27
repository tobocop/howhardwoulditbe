module Intuit
  class Request
    def initialize(user_id)
      @aggcat = Aggcat.scope(user_id)
    end

    def accounts(intuit_institution_id, user_and_password)
      @aggcat.discover_and_add_accounts(intuit_institution_id, *user_and_password)
    end

    def respond_to_mfa(intuit_institution_id, challenge_session_id, challenge_node_id, answers)
      @aggcat.account_confirmation(intuit_institution_id, challenge_session_id, challenge_node_id, answers)
    end

    def login_accounts(login_id)
      @aggcat.login_accounts(login_id)
    end
  end
end
