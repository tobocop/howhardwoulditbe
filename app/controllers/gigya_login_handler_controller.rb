class GigyaLoginHandlerController < ApplicationController
  def create
    gigya_user = Gigya::User.from_redirect_params(params.except(:controller, :action)) # handles signature verification

    user = User.find_or_create_gigya_user(gigya_user)
    if user.persisted?
      sign_in_user(user)
      redirect_to dashboard_path
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end