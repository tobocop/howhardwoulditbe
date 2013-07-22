class GigyaLoginHandlerController < ApplicationController

  include Tracking

  def create
    gigya_login_service = GigyaSocialLoginService.new(params_for_service)

    response = gigya_login_service.sign_in_user

    if response.success?
      sign_in_user(gigya_login_service.user)

      if response.new_user?
        track_email_capture_event(gigya_login_service.user.id)
        redirect_to wallet_path(link_card: true)
      else
        redirect_to wallet_path
      end
    else
      flash.notice = response.message
      redirect_to root_path
    end
  end

  private

  def params_for_service
    params.merge(gigya_connection: gigya_connection).except(:controller, :action)
  end
end