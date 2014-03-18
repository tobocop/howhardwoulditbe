module Plink
  class FishyService
    def self.user_fishy?(user_id)
      Plink::IntuitFishyTransactionRecord.active_by_user_id(user_id).present?
    end

    def self.fishy_with(user_id)
      get_all_fishy_pairs(Plink::IntuitFishyTransactionRecord.active_by_user_id(user_id)).flatten.uniq
    end

  private

    def self.get_all_fishy_pairs(intuit_fishy_transaction_records)
      intuit_fishy_transaction_records.map do |intuit_fishy_transaction_record|
        [intuit_fishy_transaction_record.user_id, intuit_fishy_transaction_record.other_fishy_user_id]
      end
    end
  end
end
