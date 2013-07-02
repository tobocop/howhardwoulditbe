class HomeController < ApplicationController

  def index
    @user_registration_form = user_registration_form
  end

  private

  def user_registration_form
    UserRegistrationForm.new
  end
end
