class UserBalance < ActiveRecord::Base
  self.table_name = 'vw_userBalances'

  def current_balance
    dollarCurrentBalance
  end
end