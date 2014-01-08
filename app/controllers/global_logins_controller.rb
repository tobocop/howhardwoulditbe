class GlobalLoginsController < ApplicationController
  include TrackingExtensions

  def new
    if !valid_login_params?
      handle_invalid_or_expired_token
      return
    end

    user = plink_user_service.find_by_id(params[:uid])
    redirect_destination = validate_login(user)

    if redirect_destination.present?
      redirect_user(user, redirect_destination)
    else
      handle_invalid_or_expired_token
    end
  end

private

  def get_global_login_token(token)
    Plink::GlobalLoginTokenRecord.existing(params[:global_token])
  end

  def valid_login_params?
    params[:uid] && params[:global_token] && params[:user_token]
  end

  def validate_login(user)
    token = get_global_login_token(params[:global_token]).first
    if token.present? && user.present? && user.login_token == params[:user_token]
      token.redirect_url
    else
      nil
    end
  end

  def redirect_user(user, redirect_destination)
    set_session_tracking_params(new_tracking_object_from_params(params))
    sign_in_user(user) unless current_user.logged_in?
    redirect_to redirect_destination
  end

  def handle_invalid_or_expired_token
    flash[:error] = 'Link expired.'
    redirect_to root_path
  end
end
