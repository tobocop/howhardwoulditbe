class IntuitAccountRequest
  attr_accessor :hash_check, :institution_id, :intuit_institution_id, :request_id, :user_id

  def initialize(user_id, institution_id, intuit_institution_id, request_id, hash_check)
    @hash_check = hash_check
    @institution_id = institution_id
    @intuit_institution_id = intuit_institution_id
    @request_id = request_id
    @user_id = user_id
  end

  def accounts(user_and_password)
    decrypted_credentials = ENCRYPTION.decrypt_and_verify(user_and_password)
    intuit_response = Intuit::Request.new(user_id).accounts(intuit_institution_id, decrypted_credentials)

    response = Intuit::Response.new(intuit_response)
    populate_staging_records(response.login_id) if response.accounts?

    update_request_record(response.parse.to_json)
  end

  def respond_to_mfa(answers, challenge_session_id, challenge_node_id, hash_check)
    answers = ENCRYPTION.decrypt_and_verify(answers)
    intuit_response = Intuit::Request.new(user_id).respond_to_mfa(intuit_institution_id, challenge_session_id, challenge_node_id, answers)

    response = Intuit::Response.new(intuit_response).parse

    if !response[:error] && response[:value].first.has_key?(:login_id)
      login_id = response[:value].first[:login_id]
      institution = Plink::InstitutionRecord.where(intuitInstitutionID: intuit_institution_id).first
      attrs = {hash_check: hash_check, login_id: login_id, institution_id: institution.id}
      users_institution = create_users_institution_record(attrs)
      create_staging_records(response[:value], users_institution.id)
    end

    update_request_record(response.to_json)
  end

private

  def populate_staging_records(login_id)
    response = login_accounts(login_id)

    if response.accounts?
      users_institution = create_users_institution_record(response.login_id)
      create_staging_records(response.accounts, users_institution.id)
    end
  end

  def login_accounts(login_id)
    intuit_response = Intuit::Request.new(user_id).login_accounts(login_id)
    response = Intuit::Response.new(intuit_response)

    if response.aggregation_error?
      error_message = error_message_from_status_code(response.first_error_status_code)
      response = {error: true, value: error_message}
    end

    response
  end

  def update_request_record(response)
    encrypted_response = ENCRYPTION.encrypt_and_sign(response)
    request = Plink::IntuitAccountRequestRecord.find(request_id)
    request.update_attributes(processed: true, response: encrypted_response)
  end

  def error_message_from_status_code(aggr_status_code)
    error_record = Plink::IntuitErrorRecord.where(intuitErrorID: aggr_status_code).first

    if !error_record
      "Failed with status code ##{aggr_status_code}. Please contact your financial institution."
    elsif error_record.user_message.blank?
      error_record.error_description
    else
      error_record.user_message
    end
  end

  def create_users_institution_record(login_id)
    users_institution_attrs = {
      hash_check: hash_check,
      intuit_institution_login_id: login_id,
      institution_id: institution_id,
      is_active: true,
      user_id: user_id
    }

    Plink::UsersInstitutionRecord.create(users_institution_attrs)
  end

  def create_staging_records(accounts, users_institution_id)
    accounts.each do |account|
      account_attrs = {
        account_id: account[:id],
        account_number_hash: account[:number_hash],
        account_number_last_four: account[:number_last_four],
        account_type: account[:type],
        account_type_description: account[:type_description],
        aggr_attempt_date: account[:aggr_attempt_date],
        aggr_status_code: account[:aggr_status_code],
        aggr_success_date: account[:aggr_success_date],
        currency_code: account[:currency_code],
        in_intuit: true,
        name: account[:name],
        status: account[:status],
        user_id: user_id,
        users_institution_id: users_institution_id
      }

      Plink::UsersInstitutionAccountStagingRecord.create(account_attrs)
    end
  end
end
