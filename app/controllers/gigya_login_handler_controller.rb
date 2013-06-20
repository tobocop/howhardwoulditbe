class GigyaLoginHandlerController < ApplicationController
  def create
    gigya_login_service = GigyaSocialLoginService.new(params_for_service)

    sign_in_user(gigya_login_service.user)
    redirect_to dashboard_path
  end

  private

  def params_for_service
    params.merge(gigya_connection: gigya_connection).except(:controller, :action)
  end
end