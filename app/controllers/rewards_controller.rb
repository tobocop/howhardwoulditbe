class RewardsController < ApplicationController


  def index
    @rewards = plink_reward_service.get_live_rewards
    @current_tab = 'rewards'
  end

  private

  def plink_reward_service
    Plink::RewardService.new
  end

end