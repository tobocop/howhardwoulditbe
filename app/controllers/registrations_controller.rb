class RegistrationsController < ApplicationController

  include Tracking
  include LyrisExtensions

  def create
    user_registration_form = UserRegistrationForm.new(
      first_name: params[:first_name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      virtual_currency_name: current_virtual_currency.currency_name,
      provider: 'organic',
      ip: request.remote_ip,
      user_agent: request.user_agent
    )

    if user_registration_form.save
      notify_gigya(user_registration_form)
      handle_events(user_registration_form.user_id)
      add_to_lyris(user_registration_form.user_id, user_registration_form.email)
      sign_in_user(user_registration_form.user)

      path = get_return_to_path || wallet_path(link_card: true)
      render json: {redirect_path: path}
    else
      render json: {
        errors: user_registration_form.errors.messages.slice(:first_name, :password, :password_confirmation, :email)
      }, status: 403
    end
  end

private

  def notify_gigya(user_registration_form)
    notification = gigya_connection.notify_login(site_user_id: user_registration_form.user_id, first_name: user_registration_form.first_name, email: user_registration_form.email, new_user: true)
    cookies[notification.cookie_name] = {value: notification.cookie_value, path: notification.cookie_path, domain: notification.cookie_domain, expires: 2.weeks.from_now.at_midnight}
  end

  def handle_events(user_id)
    update_registration_start_event(user_id)
    track_email_capture_event(user_id)
  end
end
