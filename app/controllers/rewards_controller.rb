class RewardsController < ApplicationController

  def index
    @rewards = create_reward_presenters(plink_reward_service.get_live_rewards)
    @user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    @current_tab = 'rewards'
  end

  private

  def create_reward_presenters(plink_rewards)
    plink_rewards.map {|reward| RewardPresenter.new(reward: reward, virtual_currency_presenter: current_virtual_currency)}
  end

  def plink_reward_service
    Plink::RewardService.new
  end

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end

end