class InstitutionLoginsController < ApplicationController
  def update_credentials
    users_institution_record = Plink::UsersInstitutionRecord.find(params[:id])
    session[:intuit_institution_login_id] = users_institution_record.intuit_institution_login_id

    redirect_to institution_authentication_path(users_institution_record.institution_id)
  end

  def credentials_updated
    @account_name = Plink::InstitutionRecord.find(params[:institution_id]).name
    session.delete(:intuit_institution_login_id)

    render partial: 'credentials_updated'
  end
end
