class SubscriptionsController < ApplicationController

  respond_to :json, :html

  layout 'plain'

  def edit
    @email_address = params[:email_address]
  end

  def update
    user = retrieve_user(params[:email_address])
    plink_user_service.update_subscription_preferences(user.id, is_subscribed: params[:is_subscribed]) if user.present?

    respond_to do |format|
      format.html do
        if user.present?
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

  def unsubscribe
    user = retrieve_user(params[:email_address])

    if user.present?
      plink_user_service.update_subscription_preferences(user.id, is_subscribed: 0)
      redirect_to root_url, notice: 'You have been un-subscribed.'
    else
      redirect_to root_url, notice: 'Email address does not exist in our system.'
    end
  end

  def contest_unsubscribe
    user = retrieve_user(params[:email_address])

    if user.present?
      plink_user_service.update_subscription_preferences(user.id, daily_contest_reminder: 0)
      redirect_to contests_url, notice: "You've been successfully unsubscribed from future contest notifications."
    else
      redirect_to contests_url, notice: 'Email address does not exist in our system.'
    end
  end

private

  def retrieve_user(email_address)
    plink_user_service.find_by_email(email_address)
  end

  def plink_user_service
    Plink::UserService.new
  end
end
