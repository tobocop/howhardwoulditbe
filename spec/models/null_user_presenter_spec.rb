require 'spec_helper'

describe NullUserPresenter do

  subject(:null_user_presenter) { NullUserPresenter.new }

  it 'has a nil id' do
    null_user_presenter.id.should == nil
  end

  it 'returns the default virtual currency id as its primary virtual currency id' do
    Plink::VirtualCurrency.stub(:default) { double(id: 123) }
    null_user_presenter.primary_virtual_currency_id.should == 123
  end

  it 'is not logged in' do
    null_user_presenter.should_not be_logged_in
  end

  it 'cannot redeem' do
    null_user_presenter.can_redeem?.should == false
  end

  it 'has no currency balance' do
    null_user_presenter.currency_balance.should == 0
  end
end
