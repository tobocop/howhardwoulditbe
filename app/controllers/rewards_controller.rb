class RewardsController < ApplicationController

  layout 'logged_out'

  def index
    @rewards = plink_reward_service.get_live_rewards
  end

  private

  def plink_reward_service
    Plink::RewardService.new
  end

end