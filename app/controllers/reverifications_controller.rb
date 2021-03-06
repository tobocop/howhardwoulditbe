class ReverificationsController < ApplicationController
  def start
    user_reverification = Plink::UserReverificationRecord.find(params[:id])
    user_reverification.update_attributes(started_on: Time.zone.now)
    session[:reverification_id] = user_reverification.id
    session[:intuit_institution_login_id] = user_reverification.users_institution_record.intuit_institution_login_id unless [106, 168, 324].include?(user_reverification.intuit_error_id)

    redirect_to institution_authentication_path(user_reverification.institution_record.id)
  end

  def complete
    user_reverification = Plink::UserReverificationRecord.find(session[:reverification_id])
    user_reverification.update_attributes(completed_on: Time.zone.now)
    @account_name = user_reverification.institution_record.name
    session.delete(:reverification_id)
    session.delete(:intuit_institution_login_id)

    render partial: 'complete' unless params[:full_page]
  end
end
