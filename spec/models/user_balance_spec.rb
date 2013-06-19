require 'spec_helper'

describe UserBalance do
  describe '#currency_balance' do
    it 'returns the currencyCurrentBalance' do
      user = create_user
      user_balance = UserBalance.where(userID: user.id).first
      user_balance.current_balance.should == 0
    end
  end
end
