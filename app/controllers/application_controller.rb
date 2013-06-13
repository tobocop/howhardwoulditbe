class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def sign_in_user(user)
    session[:current_user_id] = user.id
  end

  def current_user
    User.find(session[:current_user_id])
  end
end
