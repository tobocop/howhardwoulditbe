class RedemptionController < ApplicationController

  before_filter :require_authentication

  def show
    @reward = plink_reward_service.for_reward_amount(params[:reward_amount_id])
  end

  def create
    user_redemption_attempt = UserRedemptionAttempt.new(current_user.id)
    if user_redemption_attempt.valid?
      if redemption
        redirect_to redemption_path(reward_amount_id: params[:reward_amount_id])
      else
        flash[:error] = 'You do not have enough points to redeem.' unless flash[:error].present?
        redirect_to rewards_path
      end
    else
      flash[:error] = user_redemption_attempt.error_messages
      redirect_to rewards_path
    end
  end

  private

  def plink_reward_service
    Plink::RewardService.new
  end

  def plink_redemption_service
    Plink::RewardRedemptionService.new(
        user_id: current_user.id,
        reward_amount_id: params[:reward_amount_id],
        user_balance: current_user.current_balance,
        first_name: current_user.first_name,
        email: current_user.email
    )
  end

  def redemption
    begin
      plink_redemption_service.redeem
    rescue Exception => e
      ::Exceptional::Catcher.handle(e) if Rails.env.production?

      flash[:error] = 'Unable to reach Tango. Please try again later.'
      false
    end
  end
end
