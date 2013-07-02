module Plink
  class RewardService
    def get_live_rewards
      create_rewards(Plink::RewardRecord.live)
    end

    private

    def create_rewards(reward_records)
      reward_records.map { |reward_record| Reward.new(reward_record, reward_record.live_amounts) }
    end
  end
end