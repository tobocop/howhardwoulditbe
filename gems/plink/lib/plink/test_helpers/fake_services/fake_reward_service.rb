module Plink
  class FakeRewardService

    def initialize(rewards)
      @rewards = rewards
    end

    def get_live_rewards
      @rewards
    end

  end
end