class IntuitUpdateRequest
  attr_accessor :user_id, :request_id, :intuit_institution_id, :intuit_institution_login_id

  def initialize(user_id, request_id, intuit_institution_id, intuit_institution_login_id)
    @user_id = user_id
    @request_id = request_id
    @intuit_institution_id = intuit_institution_id
    @intuit_institution_login_id = intuit_institution_login_id
  end

  def authenticate(user_and_password)
    decrypted_credentials = ENCRYPTION.decrypt_and_verify(user_and_password)
    update_credentials_request = Intuit::Request.new(user_id).update_credentials(intuit_institution_id, intuit_institution_login_id, decrypted_credentials)
    response = Intuit::Response.new(update_credentials_request)
    update_request_record(response.parse.to_json)
  end

  def respond_to_mfa(answers, challenge_session_id, challenge_node_id)
    decrypted_answers = ENCRYPTION.decrypt_and_verify(answers)
    update_mfa_request = Intuit::Request.new(user_id).update_mfa(intuit_institution_login_id, challenge_session_id, challenge_node_id, decrypted_answers)
    response = Intuit::Response.new(update_mfa_request)
    update_request_record(response.parse.to_json)
  end

 private

  def update_request_record(response)
    encrypted_response = ENCRYPTION.encrypt_and_sign(response)
    request = Plink::IntuitRequestRecord.find(request_id)
    request.update_attributes(processed: true, response: encrypted_response)
  end
end
