class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'logged_in'

  helper_method :current_user, :current_virtual_currency

  def sign_in_user(user)
    session[:current_user_id] = user.id
  end

  def current_user
    return nil if session[:current_user_id].blank?
    @user ||= User.find(session[:current_user_id])
  end

  def current_virtual_currency
    currency = VirtualCurrency.where(virtualCurrencyID: current_user.primary_virtual_currency_id).first
    VirtualCurrencyPresenter.new(user_balance: current_user.current_balance, virtual_currency: currency)
  end

  def require_authentication
    redirect_to root_path unless user_logged_in?
  end

  def user_logged_in?
    current_user.present?
  end

  def gigya_connection
    @_gigya_connection ||= Gigya.new(Gigya::Config.instance)
  end
end
