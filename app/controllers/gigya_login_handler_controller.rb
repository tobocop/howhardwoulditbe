class GigyaLoginHandlerController < ApplicationController

  include Tracking

  def create
    gigya_login_service = GigyaSocialLoginService.new(params_for_service)

    response = gigya_login_service.sign_in_user

    if response.success?
      user = gigya_login_service.user

      sign_in_user(user)

      if response.new_user?
        track_email_capture_event(user.id)
        redirect_to wallet_path(link_card: true)
      else
        redirect_to redirect_path_for(user)
      end
    else
      redirect_to root_path, notice: response.message
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
    params.merge(gigya_connection: gigya_connection).except(:controller, :action)
  end

  def plink_intuit_account_service
    @plink_intuit_account_service ||= Plink::IntuitAccountService.new
  end
end