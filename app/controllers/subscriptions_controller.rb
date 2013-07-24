class SubscriptionsController < ApplicationController

  respond_to :json, :html

  layout 'plain'

  def edit
    @email_address = params[:email_address]
  end

  def update
    user = retrieve_user(params[:email_address])
    plink_user_service.update_subscription_preferences(user.id, is_subscribed: params[:is_subscribed]) if user.logged_in?

    respond_to do |format|
      format.html do
        if user.logged_in?
          redirect_to root_url, notice: 'Your subscription preferences have been successfully updated.'
        else
          redirect_to root_url, notice: 'Email address does not exist in our system.'
        end
      end

      format.json do
        render json: {}
      end
    end
  end

  def retrieve_user(email_address)
    email_address.present? ? present_user(plink_user_service.find_by_email(email_address)) : current_user
  end

  private

  def plink_user_service
    Plink::UserService.new
  end
end
