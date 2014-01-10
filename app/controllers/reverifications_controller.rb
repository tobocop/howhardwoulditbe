class ReverificationsController < ApplicationController
  def start
    user_reverification = Plink::UserReverificationRecord.find(params[:id])
    user_reverification.update_attributes(started_on: Time.zone.now)
    session[:reverification_id] = user_reverification.id
    session[:intuit_institution_login_id] = user_reverification.users_institution_record.intuit_institution_login_id

    redirect_to institution_authentication_path(user_reverification.institution_record.id)
  end

  def complete
    render partial: 'complete'
  end
end
