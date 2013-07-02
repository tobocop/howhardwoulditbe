module Plink
  class FakeRewardService

    def initialize(rewards)
      @rewards = rewards
    end

    def get_rewards
      @rewards
    end

  end
end