class SessionsController < ApplicationController

  def create
    user_session = UserSession.new(email: params[:user_session][:email], password: params[:user_session][:password])

    if user_session.valid?
      user = user_session.user

      notification = gigya_connection.notify_login(site_user_id: user_session.user_id, first_name: user_session.first_name, email: user_session.email)
      cookies[notification.cookie_name] = {value: notification.cookie_value, path: notification.cookie_path, domain: notification.cookie_domain}
      sign_in_user(user)

      render json: {redirect_path: redirect_path_for(user)}
    else
      render json: {
        errors: user_session.errors.messages
      }, status: 403
    end
  end

  def destroy
    sign_out_user
    flash[:notice] = 'You have been successfully logged out.'
    redirect_to root_path
  end

  private

  def redirect_path_for(user)
    if get_return_to_path.present?
      get_return_to_path
    elsif plink_intuit_account_service.user_has_account?(user.id)
      wallet_path
    else
      wallet_path(link_card: true)
    end
  end

  def plink_intuit_account_service
    @plink_intuit_account_service ||= Plink::IntuitAccountService.new
  end
end
