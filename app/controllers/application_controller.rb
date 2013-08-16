class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_virtual_currency, :user_logged_in?, :user_registration_form

  before_filter :redirect_white_label_members
  before_filter :auto_login_from_cookie

  def redirect_white_label_members
    if current_user.logged_in?
      virtual_currency = current_virtual_currency

      if virtual_currency.subdomain != Plink::VirtualCurrency::DEFAULT_SUBDOMAIN
        sign_out_user
        send_user_to_white_label(virtual_currency.subdomain)
      end
    end
  end

  def auto_login_from_cookie
    return if current_user.logged_in?
    return unless cookies[login_cookie_key]

    decoded_cookie = decode_plink_cookie(cookies[login_cookie_key])
    user = plink_user_service.find_by_password_hash(decoded_cookie)
    sign_in_user(user) if user
  end

  def sign_in_user(user)
    set_user_session(user.id)
    set_auto_login_cookie(user.password_hash)
  end

  def sign_out_user
    expire_user_session
    expire_auto_login_cookie
  end

  def current_user
    return NullUserPresenter.new if session[:current_user_id].blank?
    @user ||= present_user(plink_user_service.find_by_id(session[:current_user_id]))
  end

  def present_user(user)
    if user.present?
      UserPresenter.new(user: user)
    else
      NullUserPresenter.new
    end
  end

  def current_virtual_currency
    @virtual_currency ||= begin
      currency = Plink::VirtualCurrency.where(virtualCurrencyID: current_user.primary_virtual_currency_id).first
      VirtualCurrencyPresenter.new(virtual_currency: currency)
    end
  end

  def require_authentication
    flash.keep
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

  def send_user_to_white_label(subdomain)
    redirect_to white_label_url_for(subdomain)
  end

  def white_label_url_for(subdomain)
    "http://#{subdomain}.#{request.domain}"
  end

  def set_user_session(user_id)
    session[:current_user_id] = user_id
  end

  def expire_user_session
    session[:current_user_id] = nil
  end

  def plink_user_service
    Plink::UserService.new
  end

  def set_auto_login_cookie(password_hash)
    encoded_hash = encode_plink_cookie(password_hash)

    cookies[login_cookie_key] = {
      value: encoded_hash,
      domain: :all,
      path: '/'
    }
  end

  def expire_auto_login_cookie
    return unless cookies[login_cookie_key]
    cookies.delete(login_cookie_key, domain: :all, path: '/')
  end

  def encode_plink_cookie(unencoded_value)
    Base64.encode64(unencoded_value)
  end

  def decode_plink_cookie(encoded_value)
    Base64.decode64(encoded_value)
  end

  def login_cookie_key
    :PLINKUID
  end
end
