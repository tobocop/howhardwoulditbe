class SubscriptionsController < ApplicationController

  respond_to :json, :html

  def edit
    @email_address = params[:email_address]
  end

  def update
    user = params[:email_address].present? ? plink_user_service.find_by_email(params[:email_address]) : current_user
    plink_user_service.update_subscription_preferences(user.id, is_subscribed: params[:is_subscribed])

    respond_to do |format|
      format.html do
        redirect_to root_url, notice: 'Your subscription preferences have been successfully updated.'
      end

      format.json do
        render json: {}
      end
    end
  end

  private

  def plink_user_service
    Plink::UserService.new
  end
end
