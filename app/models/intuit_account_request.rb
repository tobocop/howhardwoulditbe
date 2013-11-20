class IntuitAccountRequest
  attr_accessor :intuit_institution_id, :request_id, :user_and_password, :user_id

  def initialize(user_id, user_and_password, intuit_institution_id, request_id)
    @intuit_institution_id = intuit_institution_id
    @request_id = request_id
    @user_and_password = user_and_password
    @user_id = user_id
  end

  def accounts
    decrypted_credentials = ENCRYPTION.decrypt_and_verify(@user_and_password)
    intuit_response = Aggcat.scope(user_id).
      discover_and_add_accounts(intuit_institution_id, *decrypted_credentials)

    response = parse_response(intuit_response)
    update_request_record(ENCRYPTION.encrypt_and_sign(response.to_json))
  end

  def respond_to_mfa(answers, challenge_session_id, challenge_node_id)
    answers = ENCRYPTION.decrypt_and_verify(answers)
    intuit_response = Aggcat.scope(user_id).
      account_confirmation(intuit_institution_id, challenge_session_id, challenge_node_id, answers)

    response = parse_response(intuit_response)
    update_request_record(ENCRYPTION.encrypt_and_sign(response.to_json))
  end

private

  def parse_response(intuit_response)
    if successful?(intuit_response)
      {error: false, value: banking_and_credit_accounts(intuit_response)}
    elsif mfa?(intuit_response)
      challenge_session_id = intuit_response[:challenge_session_id]
      challenge_node_id = intuit_response[:challenge_node_id]
      value = {questions: mfa_questions(intuit_response), challenge_session_id: challenge_session_id, challenge_node_id: challenge_node_id}

      {error: false, mfa: true, value: value}
    else
      {error: true, value: error_message(intuit_response)}
    end
  end

  def successful?(intuit_response)
    intuit_response[:status_code] == '201'
  end

  def mfa?(intuit_response)
    intuit_response[:status_code] == '401'
  end

  def update_request_record(encrypted_response)
    request = Plink::IntuitAccountRequestRecord.find(request_id)
    request.update_attributes(processed: true, response: encrypted_response)
  end

  def banking_and_credit_accounts(intuit_response)
    accounts = InstitutionAccountsPresenter.new(intuit_response[:result][:account_list])
    accounts.banking_and_credit.map{|account| account.to_hash}
  end

  def mfa_questions(intuit_response)
    intuit_response[:result][:challenges][:challenge]
  end

  def error_message(intuit_response)
    intuit_response[:result][:status][:error_info][:error_message]
  end
end
