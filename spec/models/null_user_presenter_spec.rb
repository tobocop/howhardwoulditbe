require 'spec_helper'

describe NullUserPresenter do

  it 'returns the default virtual currency id as its primary virtual currency id' do
    Plink::VirtualCurrency.stub(:default) { stub(id: 123) }
    NullUserPresenter.new.primary_virtual_currency_id.should == 123
  end

  it 'is not logged in' do
    NullUserPresenter.new.should_not be_logged_in
  end
end