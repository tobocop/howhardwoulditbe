class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_virtual_currency, :user_logged_in?, :user_registration_form

  before_filter :redirect_white_label_members

  def redirect_white_label_members
    if current_user.logged_in?
      virtual_currency = current_virtual_currency

      if virtual_currency.subdomain != Plink::VirtualCurrency::DEFAULT_SUBDOMAIN
        send_user_to_white_label(current_user, virtual_currency.subdomain)
      end
    end
  end

  def sign_in_user(user)
    set_user_session(user.id)
    set_coldfusion_login_cookie(user.password_hash)
  end

  def current_user
    return NullUserPresenter.new if session[:current_user_id].blank?
    @user ||= UserPresenter.new(user: plink_user_service.find_by_id(session[:current_user_id]))
  end

  def current_virtual_currency
    @virtual_currency ||= begin
      currency = Plink::VirtualCurrency.where(virtualCurrencyID: current_user.primary_virtual_currency_id).first
      VirtualCurrencyPresenter.new(virtual_currency: currency)
    end
  end

  def require_authentication
    redirect_to root_path unless user_logged_in?
  end

  def user_logged_in?
    current_user.logged_in?
  end

  def gigya_connection
    @_gigya_connection ||= Gigya.new(Gigya::Config.instance)
  end

  def user_must_be_linked
    raise 'User account must be linked' unless Plink::IntuitAccountService.new.user_has_account?(current_user.id)
  end

  def user_registration_form
    @_user_registration_form ||= UserRegistrationForm.new
  end

  private

  def send_user_to_white_label(user, subdomain)
    sign_in_user(user)
    redirect_to white_label_url_for(subdomain)
  end

  def white_label_url_for(subdomain)
    "http://#{subdomain}.#{request.host}"
  end

  def set_user_session(user_id)
    session[:current_user_id] = user_id
  end

  def plink_user_service
    Plink::UserService.new
  end

  def set_coldfusion_login_cookie(password_hash)
    encoded_hash = Base64.encode64(password_hash)

    cookies[:PLINKUID] = {
      value: encoded_hash,
      domain: :all,
      path: '/'
    }
  end

end
