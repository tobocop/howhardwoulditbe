module Plink
  class TransactionEligibleForBonusRecord < ActiveRecord::Base
    self.table_name = 'transactions_eligible_for_bonus'

    attr_accessible :intuit_transaction_id, :offer_id, :offers_virtual_currency_id,
      :processed, :user_id

    belongs_to :user_record, class_name: 'Plink::UserRecord', foreign_key: 'user_id'
  end
end
