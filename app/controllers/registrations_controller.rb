class RegistrationsController < ApplicationController

  include Tracking

  def create
    user_registration_form = UserRegistrationForm.new(
      email: params[:email],
      first_name: params[:first_name],
      ip: request.remote_ip,
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      provider: 'organic',
      user_agent: request.user_agent,
      virtual_currency_name: current_virtual_currency.currency_name
    )

    if user_registration_form.save
      notify_gigya(user_registration_form)
      handle_events(user_registration_form.user_id)
      sign_in_user(user_registration_form.user)
      add_user_to_lyris(user_registration_form.user_id, user_registration_form.email, current_virtual_currency.currency_name)

      path = get_return_to_path || link_card_or_institution_search
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

  def add_user_to_lyris(user_id, email, currency_name)
    Lyris::UserService.delay.add_to_lyris(user_id, email, currency_name)
  end
end
