module Plink
  class FishyService
    def self.user_fishy?(user_id)
      Plink::IntuitFishyTransactionRecord.active_by_user_id(user_id).present?
    end
  end
end
