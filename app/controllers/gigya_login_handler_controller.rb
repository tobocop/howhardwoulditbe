class GigyaLoginHandlerController < ApplicationController

  include Tracking

  def create
    gigya_login_service = GigyaSocialLoginService.new(params_for_service)

    response = gigya_login_service.sign_in_user

    if response.success?
      user = gigya_login_service.user

      sign_in_user(user)

      if response.new_user?
        update_registration_start_event(user.id)
        track_email_capture_event(user.id)
        mail_user(user.id)
        add_user_to_lyris(user.id, user.email, current_virtual_currency.currency_name)

        path =
          if session[:share_page_id].present? && params[:loginProvider] == 'facebook'
            share_page_path(id: session[:share_page_id])
          else
            get_return_to_path || wallet_path(link_card: true)
          end

        redirect_to path
      else
        redirect_to get_return_to_path || redirect_path_for(user)
      end
    else
      redirect_to get_return_to_path || root_path, notice: response.message
    end
  end

private

  def mail_user(user_id)
    AfterUserRegistration.delay(run_at: 20.minutes.from_now).send_complete_your_registration_email(user_id)
  end

  def redirect_path_for(user)
    if plink_intuit_account_service.user_has_account?(user.id)
      wallet_path
    else
      wallet_path(link_card: true)
    end
  end

  def params_for_service
    params.merge(
      gigya_connection: gigya_connection,
      ip: request.remote_ip,
      user_agent: request.user_agent
    ).except(:controller, :action)
  end

  def plink_intuit_account_service
    @plink_intuit_account_service ||= Plink::IntuitAccountService.new
  end

  def add_user_to_lyris(user_id, email, currency_name)
    Lyris::UserService.delay.add_to_lyris(user_id, email, currency_name)
  end
end
