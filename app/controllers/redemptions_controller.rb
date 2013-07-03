class RedemptionsController < ApplicationController

  before_filter :require_authentication

  def create
    if ActiveIntuitAccount.user_has_account?(current_user.id)
      redemption = plink_redemption_service.create_pending(
          user_id: current_user.id,
          reward_amount_id: params[:reward_amount_id],
          user_balance: current_user.current_balance
      )
      flash[:error] = 'You do not have enough points to redeem.' unless redemption
    else
      flash[:error] = 'You must have a linked card to redeem an award.'
    end

    redirect_to rewards_path
  end

  private

  def plink_redemption_service
    Plink::RedemptionService.new
  end
end