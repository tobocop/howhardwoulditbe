module Plink
  class RewardService
    def get_rewards
      create_rewards(Plink::RewardRecord.all)
    end

    private

    def create_rewards(reward_records)
      reward_records.map { |reward_record| Reward.new(reward_record) }
    end
  end
end