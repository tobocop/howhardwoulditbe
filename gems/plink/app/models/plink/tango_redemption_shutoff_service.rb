module Plink
  class TangoRedemptionShutoffService
    def self.halt_redemptions
      Plink::RewardRecord.all.each do |reward|
        reward.update_attributes(is_active: false) if reward.is_tango
      end
    end
  end
end