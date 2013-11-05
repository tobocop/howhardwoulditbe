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
    update_request_record(request_id, ENCRYPTION.encrypt_and_sign(response.to_json))
  end

private

  def parse_response(intuit_response)
    if successful?(intuit_response)
      {error: false, value: banking_and_credit_accounts(intuit_response)}
    else
      {error: true, value: error_message(intuit_response)}
    end
  end

  def successful?(intuit_response)
    intuit_response[:status_code] == '201'
  end

  def update_request_record(request_id, encrypted_response)
    request = Plink::IntuitAccountRequestRecord.find(request_id)
    request.update_attributes(processed: true, response: encrypted_response)
  end

  def banking_and_credit_accounts(intuit_response)
    accounts = InstitutionAccountsPresenter.new(intuit_response[:result][:account_list])
    accounts.banking_and_credit.map{|account| account.to_hash}
  end

  def error_message(intuit_response)
    intuit_response[:result][:status][:error_info][:error_message]
  end
end
