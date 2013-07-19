module Plink
  class RewardService
    def get_live_rewards
      create_rewards(Plink::RewardRecord.live)
    end

    def for_reward_amount(reward_amount_id)
      reward_amount_record = Plink::RewardAmountRecord.where(lootAmountID: reward_amount_id).first
      create_reward(reward_record: reward_amount_record.reward_record, reward_amount_records: [reward_amount_record])
    end

    private

    def create_rewards(reward_records)
      reward_records.map do |reward_record|
        create_reward(reward_record: reward_record, reward_amount_records: reward_record.live_amounts)
      end
    end

    def create_reward(attributes)
      reward = attributes[:reward_record]

      Reward.new(
        {
          id: reward.id,
          name: reward.name,
          description: reward.description,
          logo_url: reward.logo_url,
          terms: reward.terms
        }, attributes[:reward_amount_records])
    end
  end
end