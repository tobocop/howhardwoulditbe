class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_virtual_currency, :user_logged_in?, :user_registration_form

  before_filter :auto_login_from_cookie
  before_filter :contest_notification_for_user
  before_filter :redirect_white_label_members

  def redirect_white_label_members
    if current_user.logged_in?
      virtual_currency = current_virtual_currency

      if virtual_currency.subdomain != Plink::VirtualCurrency::DEFAULT_SUBDOMAIN
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
    SocialProfileService.delay.get_users_social_profile(user.id)
  end

  def sign_out_user
    expire_user_session
    expire_cookies
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

  def get_return_to_path(new_user=false)
    return nil unless request.referer.present?
    referer_path = URI(request.referer).path

    if referer_path.match(/^#{contests_path}/)
      id = referer_path.match(/[1-9]$/)
      options = new_user ? {share_modal: true} : {}

      id ? contest_path(id, options) : contests_path(options)
    else
      nil
    end
  end

  def contest_notification_for_user
    user_id = current_user.id
    return false if user_id.blank?

    if current_virtual_currency.subdomain != Plink::VirtualCurrency::DEFAULT_SUBDOMAIN || contest_cookie_present?
      return
    else
      notification_data = ContestNotification.for_user(user_id, params[:contest_id])
      @notification = ContestNotificationPresenter.new(notification_data) if notification_data.present?
    end
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

  def set_auto_login_cookie(password_hash, options={})
    encoded_hash = encode_plink_cookie(password_hash)

    defaults = {
      value: encoded_hash,
      domain: :all,
      path: '/'
    }

    cookies[login_cookie_key] = defaults.merge(options)
  end

  def expire_cookies
    [login_cookie_key, :CFID, :CFTOKEN].each do |cookie_key|
      next unless cookies[cookie_key]
      cookies.delete(cookie_key, domain: :all, path: '/')
    end
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

  def has_contest_entries_today?
    Plink::EntryRecord.entries_today_for_user(current_user.id).exists?
  end

  def contest_cookie_present?
    !cookies['contest_notification'].blank?
  end
end
