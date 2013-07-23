class SubscriptionsController < ApplicationController
  def update
    plink_user_service.update_subscription_preferences(current_user.id, is_subscribed: params[:is_subscribed])
    render json: {}
  end

  private

  def plink_user_service
    Plink::UserService.new
  end
end
