class UserBalance < ActiveRecord::Base
  self.table_name = 'vw_userBalances'

  def current_balance
    dollarCurrentBalance
  end

  def lifetime_balance
    lifetimeBalance
  end

  def can_redeem?
    canRedeem == 0 ? false : true
  end
end
