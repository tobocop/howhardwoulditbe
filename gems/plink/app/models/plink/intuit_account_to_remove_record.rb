module Plink
  class IntuitAccountToRemoveRecord < ActiveRecord::Base
    self.table_name = 'intuit_accounts_to_remove'

    attr_accessible :intuit_account_id, :users_institution_id, :user_id
  end
end
