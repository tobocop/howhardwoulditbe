module Plink
  class IntuitTransactionRecord < ActiveRecord::Base
    self.table_name = 'intuit_transactions'

    attr_accessible :account_id, :advertiser_id, :amount, :hashed_value, :intuit_transaction_id,
      :job_id, :offer_id, :offers_virtual_currency_id, :payee_name, :post_date,:search_pattern_id,
      :task_id, :tier_id, :uia_account_id, :user_id, :users_institution_id, :users_virtual_currency_id,
      :virtual_currency_id
  end
end