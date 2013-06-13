class RegistrationsController < ApplicationController

  def new
    @user_registration_form = UserRegistrationForm.new
  end

  def create
    @user_registration_form = UserRegistrationForm.new(params[:user_registration_form])

    if @user_registration_form.save
      sign_in_user(@user_registration_form.user)
      redirect_to dashboard_path
    else
      render :new
    end
  end
end