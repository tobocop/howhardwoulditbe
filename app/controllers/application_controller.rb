class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def sign_in_user(user)
    session[:current_user_id] = user.id
  end

  def current_user
    return nil if session[:current_user_id].blank?
    @user ||= User.find(session[:current_user_id])
  end

  def require_authentication
    redirect_to root_path unless user_logged_in?
  end

  def user_logged_in?
    current_user.present?
  end
end
