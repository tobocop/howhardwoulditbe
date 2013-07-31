require 'spec_helper'

describe NullUserPresenter do

  subject { NullUserPresenter.new }

  it 'returns the default virtual currency id as its primary virtual currency id' do
    Plink::VirtualCurrency.stub(:default) { stub(id: 123) }
    subject.primary_virtual_currency_id.should == 123
  end

  it 'is not logged in' do
    subject.should_not be_logged_in
  end

  it 'cannot redeem' do
    subject.can_redeem?.should == false
  end
end