module Plink
  class RewardService
    def get_live_rewards
      create_rewards(Plink::RewardRecord.live)
    end

    private

    def create_rewards(reward_records)
      reward_records.map do |reward_record|
        Reward.new(
          {
            name: reward_record.name,
            description: reward_record.description,
            logo_url: reward_record.logo_url
          }, reward_record.live_amounts)
      end
    end
  end
end