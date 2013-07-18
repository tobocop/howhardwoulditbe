class RedemptionController < ApplicationController

  before_filter :require_authentication

  def create
    if plink_intuit_account_service.user_has_account?(current_user.id)
      redemption = plink_redemption_service.redeem
      flash[:error] = 'You do not have enough points to redeem.' unless redemption
    else
      flash[:error] = 'You must have a linked card to redeem an award.'
    end

    redirect_to rewards_path
  end

  private

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