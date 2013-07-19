class RedemptionController < ApplicationController

  before_filter :require_authentication

  def show
    @reward = plink_reward_service.for_reward_amount(params[:reward_amount_id])
  end

  def create
    if plink_intuit_account_service.user_has_account?(current_user.id)
      redemption = plink_redemption_service.redeem

      if redemption
        redirect_to redemption_path(reward_amount_id: params[:reward_amount_id])
      else
        flash[:error] = 'You do not have enough points to redeem.' unless redemption
        redirect_to rewards_path
      end
    else
      flash[:error] = 'You must have a linked card to redeem an award.'
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

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end
end