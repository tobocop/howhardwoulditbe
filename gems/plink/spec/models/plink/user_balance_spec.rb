require 'spec_helper'

describe Plink::UserBalance do
  describe '#current_balance' do
    it 'returns the dollarCurrentBalance' do
      user = create_user
      user_balance = Plink::UserBalance.where(userID: user.id).first
      user_balance.current_balance.should == 0
    end
  end

  describe '#currency_balance' do
    it 'returns the currencyCurrentBalance' do
      user = create_user
      user_balance = Plink::UserBalance.where(userID: user.id).first
      user_balance.currency_balance.should == 0
    end
  end

  describe '#lifetime_total' do
    it 'returns the lifetimeBalance' do
      user = create_user
      user_balance = Plink::UserBalance.where(userID: user.id).first
      user_balance.lifetime_balance.should == 0
    end
  end

  describe '#can_redeem?' do
    it 'returns whether the user can redeem their currency' do
      user = create_user
      user_balance = Plink::UserBalance.where(userID: user.id).first
      user_balance.can_redeem?.should == false
    end
  end
end
