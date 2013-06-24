class RegistrationsController < ApplicationController
  layout 'logged_out'

  def new
    @user_registration_form = UserRegistrationForm.new
  end

  def create
    @user_registration_form = UserRegistrationForm.new(params[:user_registration_form])

    if @user_registration_form.save
      notification = gigya_connection.notify_login(site_user_id: @user_registration_form.user_id, first_name: @user_registration_form.first_name, email: @user_registration_form.email, new_user: true)
      cookies[notification.cookie_name] = {value: notification.cookie_value, path: notification.cookie_path, domain: notification.cookie_domain, expires: 2.weeks.from_now.at_midnight}
      sign_in_user(@user_registration_form.user)
      redirect_to dashboard_path
    else
      render :new
    end
  end
end
