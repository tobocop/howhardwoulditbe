class RegistrationsController < ApplicationController

  include Tracking

  def create
    user_registration_form = UserRegistrationForm.new(
      first_name: params[:first_name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if user_registration_form.save
      notify_gigya(user_registration_form)
      track_email_capture_event(user_registration_form.user_id)
      sign_in_user(user_registration_form.user)

      render json: {}
    else
      render json: {
        error_message: 'Please Correct the below errors:',
        errors: user_registration_form.errors.messages.slice(:first_name, :password, :password_confirmation, :email)
      }, status: 403
    end
  end

  private

  def notify_gigya(user_registration_form)
    notification = gigya_connection.notify_login(site_user_id: user_registration_form.user_id, first_name: user_registration_form.first_name, email: user_registration_form.email, new_user: true)
    cookies[notification.cookie_name] = {value: notification.cookie_value, path: notification.cookie_path, domain: notification.cookie_domain, expires: 2.weeks.from_now.at_midnight}
  end

end
