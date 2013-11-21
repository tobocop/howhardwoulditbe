module Plink
  class IntuitTransactionStagingRecord < ActiveRecord::Base
    self.table_name = 'intuit_transactions_staging'

    attr_accessible :account_id, :advertiser_id, :amount, :business_rule_reason_id,
      :hashed_value, :intuit_transaction_id, :is_fishy, :is_in_wallet, :is_intuit_pending,
      :is_nonqualified, :is_over_minimum_amount, :is_qualified, :is_return,
      :is_search_pattern_pending, :job_id, :offer_id, :offers_virtual_currency_id,
      :payee_name, :post_date, :search_pattern_id, :task_id, :tier_id, :uia_account_id,
      :user_id, :users_institution_id, :users_virtual_currency_id, :virtual_currency_id
  end

end


