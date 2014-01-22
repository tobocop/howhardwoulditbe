module Plink
  class ReferralService
    REFERRAL_BONUS_DOLLAR_AMOUNT = 1.00

    def self.award_referral(referring_user_id, created_user_id)
      referring_user_id = referring_user_id.to_i
      if referring_user_id > 0
        Plink::FreeAwardService.new(REFERRAL_BONUS_DOLLAR_AMOUNT).award_referral_bonus(referring_user_id)
        Plink::WalletItemUnlockingService.unlock_referral_slot(referring_user_id)
        Plink::ReferralConversionRecord.create({referred_by: referring_user_id, created_user_id: created_user_id})
      end
    end
  end
end
