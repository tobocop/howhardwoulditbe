class InstitutionsController < ApplicationController
  before_filter :require_authentication
  before_filter :most_popular, only: [:search, :search_results]

  def search
    redirect_to wallet_path(link_card: true) if Rails.env.production?
  end

  def search_results
    flash.clear

    if params[:institution_name].blank?
      flash[:error] = 'Please provide a bank name or URL'
    else
      @results = Plink::InstitutionRecord.search(params[:institution_name])
      @has_unsupported_banks = @results.map(&:is_supported?).include?(false)
    end
  end

  def authentication
    @institution = Plink::InstitutionRecord.where(institutionID: params[:id]).first

    if @institution.nil?
      flash[:error] = 'Invalid institution provided. Please try again.'
      redirect_to institution_search_path
    else
      institution_form(intuit_institution_data(@institution.intuit_institution_id), @institution)
      session[:institution_id] = @institution.id
      session[:intuit_institution_id] = @institution_form.intuit_institution_id
    end
  end

  def authenticate
    Plink::IntuitAccountRequestRecord.where(user_id: current_user.id).delete_all
    request = Plink::IntuitAccountRequestRecord.create!(user_id: current_user.id, processed: false)
    session[:intuit_account_request_id] = request.id

    user_and_password = params[:field_labels].sort.map { |label| params[label] }

    set_users_institutions_hash

    intuit_accounts(user_and_password)

    render nothing: true
  end

  def poll
    request = Plink::IntuitAccountRequestRecord.where(user_id: current_user.id, processed: true).first

    if request.present?
      response = JSON.parse(ENCRYPTION.decrypt_and_verify(request.response))
      request.destroy
      @institution = Plink::InstitutionRecord.where(intuitInstitutionID: session[:intuit_institution_id]).first

      if response['mfa']
        session[:challenge_session_id] = response['value']['challenge_session_id']
        session[:challenge_node_id] = response['value']['challenge_node_id']
        questions = response['value']['questions'].is_a?(Hash) ? [response['value']['questions']] : response['value']['questions']

        render partial: 'institutions/authentication/mfa', locals: {questions: questions}
      elsif !response['error']
        render partial: 'select_account', locals: {accounts: Array(response['value'])}
      else
        institution_form(intuit_institution_data(@institution.intuit_institution_id), @institution)

        locals = {institution_form: @institution_form, institution: @institution, error: response['value']}
        render partial: 'institutions/authentication/form', locals: locals
      end
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  def text_based_mfa
    Plink::IntuitAccountRequestRecord.where(user_id: current_user.id).delete_all
    request = Plink::IntuitAccountRequestRecord.create!(user_id: current_user.id, processed: false)
    session[:intuit_account_request_id] = request.id

    intuit_mfa(parse_answers)

    render nothing: true
  end

  def select
    render :congratulations
  end

private

  def most_popular
    @most_popular ||= Plink::InstitutionRecord.most_popular
  end

  def intuit_accounts(user_and_password)
    encrypted_creds = ENCRYPTION.encrypt_and_sign(user_and_password)

    intuit_request.delay(priority: -100).accounts(encrypted_creds, session[:users_institution_hash])
  end

  def parse_answers
    questions = params.keys.grep(/mfa_question/).sort
    questions.map {|question| params[question]}
  end

  def intuit_mfa(answers)
    encrypted_answers = ENCRYPTION.encrypt_and_sign(answers)

    intuit_request.delay(priority: -100).respond_to_mfa(encrypted_answers, session[:challenge_session_id], session[:challenge_node_id])
  end

  def intuit_request
    IntuitAccountRequest.new(current_user.id, session[:institution_id], session[:intuit_institution_id], session[:intuit_account_request_id])
  end

  def institution_form(intuit_institution_data, institution)
    institution_params = intuit_institution_data[:result].merge(institution: institution)
    @institution_form = InstitutionFormPresenter.new(institution_params)

    set_non_masked_fields(@institution_form.raw_form_data)
  end

  def set_non_masked_fields(intuit_form_fields)
    non_masked_fields = []
    intuit_form_fields.each_with_index do |form_field, index|
      non_masked_fields << "auth_#{index+1}" if form_field[:mask] == 'false'
    end

    session[:non_masked_fields] = non_masked_fields
  end

  def set_users_institutions_hash
    result = ''

    params.sort.each do |param_and_value|
      field_name = param_and_value.first
      next unless session[:non_masked_fields].include?(field_name)
      value = param_and_value.last

      result << value
    end

    # If every field is masked, use the first response instead:
    if result.blank? && params[:auth_1]
      result = params[:auth_1]
    end

    session[:users_institution_hash] = Digest::SHA512.hexdigest(result)
  end

  def intuit_institution_data(intuit_institution_id)
    IntuitInstitutionRequest.institution_data(current_user.id, intuit_institution_id)
  end
end
