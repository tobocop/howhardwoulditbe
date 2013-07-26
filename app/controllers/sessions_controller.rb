class SessionsController < ApplicationController

  def create
    user_session = UserSession.new(email: params[:user_session][:email], password: params[:user_session][:password])

    if user_session.valid?
      notification = gigya_connection.notify_login(site_user_id: user_session.user_id, first_name: user_session.first_name, email: user_session.email)
      cookies[notification.cookie_name] = {value: notification.cookie_value, path: notification.cookie_path, domain: notification.cookie_domain}
      sign_in_user(user_session.user)
      render json: {}
    else
      render json: {
        error_message: 'Please Correct the below errors:',
        errors: user_session.errors.messages
      }, status: 403
    end
  end

  def destroy
    sign_out_user
    flash[:notice] = 'You have been successfully logged out.'
    redirect_to root_path
  end
end