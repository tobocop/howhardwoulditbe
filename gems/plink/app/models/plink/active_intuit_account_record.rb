module Plink
  class ActiveIntuitAccountRecord < ActiveRecord::Base

    self.table_name = 'vw_active_intuit_accounts'

    def self.user_has_account?(user_id)
      where(user_id: user_id).first.present?
    end

  end
end