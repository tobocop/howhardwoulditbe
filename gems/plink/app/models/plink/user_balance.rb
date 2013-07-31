module Plink
  class UserBalance < ActiveRecord::Base
    self.table_name = 'vw_userBalances'

    def current_balance
      dollarCurrentBalance
    end

    def currency_balance
      currencyCurrentBalance
    end

    def lifetime_balance
      lifetimeBalance
    end

    def can_redeem?
      canRedeem == 0 ? false : true
    end
  end
end
