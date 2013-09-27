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
        redirect_to get_return_to_path || wallet_path(link_card: true)
      else
        redirect_to get_return_to_path || redirect_path_for(user)
      end
    else
      redirect_to get_return_to_path || root_path, notice: response.message
    end
  end

  private

  def redirect_path_for(user)
    if plink_intuit_account_service.user_has_account?(user.id)
      wallet_path
    else
      wallet_path(link_card: true)
    end
  end

  def params_for_service
    params.merge(gigya_connection: gigya_connection, ip: request.remote_ip).except(:controller, :action)
  end

  def plink_intuit_account_service
    @plink_intuit_account_service ||= Plink::IntuitAccountService.new
  end
end
