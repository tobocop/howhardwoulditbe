module Plink
  class TangoRedemptionShutoffService
    def self.halt_redemptions
      Plink::RewardRecord.all.each do |reward|
        reward.update_attributes(is_redeemable: false) if reward.is_tango
      end
    end

    def self.resume_redemptions
      Plink::RewardRecord.all.each do |reward|
        reward.update_attributes(is_redeemable: true) if reward.is_tango
      end
    end
  end
end
