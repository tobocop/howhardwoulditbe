module Intuit
  class Request
    def initialize(user_id)
      @aggcat = Aggcat.scope(user_id)
      @user_id = user_id
    end

    def accounts(intuit_institution_id, user_and_password)
      method_and_params = {method: :discover_and_add_accounts, params: {intuit_institution_id: intuit_institution_id}}

      response = @aggcat.discover_and_add_accounts(intuit_institution_id, *user_and_password)
      log_and_return_response(response, method_and_params)
    end

    def account(account_id)
      method_and_params = {method: :account, params: {account_id: account_id}}

      log_and_return_response(@aggcat.account(account_id), method_and_params)
    end

    def respond_to_mfa(intuit_institution_id, challenge_session_id, challenge_node_id, answers)
      method_and_params = {
        method: :account_confirmation,
        params: {challenge_session_id: challenge_session_id, challenge_node_id: challenge_node_id}
      }

      response = @aggcat.account_confirmation(intuit_institution_id, challenge_session_id, challenge_node_id, answers)
      log_and_return_response(response, method_and_params)
    end

    def update_credentials(intuit_institution_id, intuit_institution_login_id, user_and_password)
      method_and_params = {method: :update_login, params: {intuit_institution_id: intuit_institution_id, login_id: intuit_institution_login_id}}

      response = @aggcat.update_login(intuit_institution_id, intuit_institution_login_id, *user_and_password)
      log_and_return_response(response, method_and_params)
    end

    def update_mfa(intuit_institution_login_id, challenge_session_id, challenge_node_id, answers)
      method_and_params = {
        method: :update_login_confirmation,
        params: {
          challenge_session_id: challenge_session_id,
          challenge_node_id: challenge_node_id,
          login_id: intuit_institution_login_id
        }
      }

      response = @aggcat.update_login_confirmation(intuit_institution_login_id, challenge_session_id, challenge_node_id, answers)
      log_and_return_response(response, method_and_params)
    end

    def login_accounts(login_id)
      method_and_params = {method: :login_accounts, params: {login_id: login_id}}

      response = @aggcat.login_accounts(login_id)
      log_and_return_response(response, method_and_params)
    end

    def institution_data(intuit_institution_id)
      method_and_params = {method: :institution, params: {intuit_institution_id: intuit_institution_id}}

      response = @aggcat.institution(intuit_institution_id)
      log_and_return_response(response, method_and_params)
    end

    def institutions
      method_and_params = {method: :institution}

      response = @aggcat.institutions
      log_and_return_response(response, method_and_params)
    end

    def update_account_type(account_id, account_type)
      method_and_params = {method: :update_account_type, params: {account_id: account_id, account_type: account_type}}

      response = @aggcat.update_account_type(account_id, account_type)
      log_and_return_response(response, method_and_params)
    end

    def get_transactions(account_id, start_date, end_date=nil)
      method_and_params = {method: :account_transactions, params: {account_id: account_id, start_date: start_date, end_date: end_date}}

      response = @aggcat.account_transactions(account_id, start_date, end_date)
      log_and_return_response(response, method_and_params)
    end

    def delete_account(intuit_account_id)
      method_and_params = {method: :delete_account, params: {intuit_account_id: intuit_account_id}}

      response = @aggcat.delete_account(intuit_account_id)
      log_and_return_response(response, method_and_params)
    end

  private

    def log_and_return_response(intuit_response, method_and_params)
      Intuit::Logger.new.log_and_return_response(intuit_response, @user_id, method_and_params)
    end
  end
end
