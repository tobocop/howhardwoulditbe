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
    end
  end

  def authentication
    institution = Plink::InstitutionRecord.where(institutionID: params[:id]).first

    if institution.nil?
      flash[:error] = 'Invalid institution provided. Please try again.'
      redirect_to institution_search_path
    else
      institution_form(intuit_institution_data(institution.intuit_institution_id), institution)
      session[:intuit_institution_id] = @institution_form.intuit_institution_id
    end
  end

  def authenticate
    Plink::IntuitAccountRequestRecord.where(user_id: current_user.id).delete_all
    request = Plink::IntuitAccountRequestRecord.create!(user_id: current_user.id, processed: false)
    session[:intuit_account_request_id] = request.id

    user_and_password = params[:field_labels].map { |label| params[label] }
    intuit_accounts(user_and_password)

    render nothing: true
  end

  def poll
    request = Plink::IntuitAccountRequestRecord.where(user_id: current_user.id, processed: true).first

    if request.present?
      accounts = JSON.parse(ENCRYPTION.decrypt_and_verify(request.response))

      if !accounts['error']
        render partial: 'select_account', locals: {accounts: accounts['value']}
      else
        institution = Plink::InstitutionRecord.where(intuitInstitutionID: session[:intuit_institution_id]).first
        institution_form(intuit_institution_data(institution.intuit_institution_id), institution)

        render partial: 'institutions/authentication/form', locals: {institution_form: @institution_form, error: accounts['value']}
      end
    else
      render nothing: true, status: :unprocessable_entity
    end
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

    request = IntuitAccountRequest.new(current_user.id, encrypted_creds, session[:intuit_institution_id], session[:intuit_account_request_id])
    request.delay(priority: -100).accounts
  end

  def institution_form(intuit_institution_data, institution)
    institution_params = intuit_institution_data[:result].merge(institution: institution)
    @institution_form = InstitutionFormPresenter.new(institution_params)
  end

  def intuit_institution_data(intuit_institution_id)
    IntuitInstitutionRequest.institution_data(current_user.id, intuit_institution_id)
  end
end
