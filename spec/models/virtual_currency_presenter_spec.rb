require 'spec_helper'

describe VirtualCurrencyPresenter do

  describe '.new' do
    it 'raises when a user_balance is not provided' do
      expect {
        presenter = VirtualCurrencyPresenter.new(virtual_currency: stub)
      }.to raise_error(KeyError, 'key not found: :user_balance')
    end

    it 'raises when a virtual currency is not provided' do
      expect {
        presenter = VirtualCurrencyPresenter.new(user_balance: 1.0)
      }.to raise_error(KeyError, 'key not found: :virtual_currency')
    end
  end

  describe '#users_balance' do
    it 'returns the balance passed in' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.0, virtual_currency: stub)
      presenter.user_balance.should === '1'
    end
  end

  describe '#currency_name' do
    it 'returns the name of the provided currency' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.0, virtual_currency: stub(name: 'Plonk Points'))
      presenter.currency_name.should == 'Plonk Points'
    end
  end
end
