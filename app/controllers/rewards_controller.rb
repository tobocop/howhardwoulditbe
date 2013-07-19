class RewardsController < ApplicationController

  def index
    @rewards = create_reward_presenters(plink_reward_service.get_live_rewards)
    @current_tab = 'rewards'
  end

  private

  def create_reward_presenters(plink_rewards)
    plink_rewards.map {|reward| RewardPresenter.new(reward: reward, virtual_currency_presenter: current_virtual_currency)}
  end

  def plink_reward_service
    Plink::RewardService.new
  end

end