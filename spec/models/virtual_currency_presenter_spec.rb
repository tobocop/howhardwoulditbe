require 'spec_helper'

describe VirtualCurrencyPresenter do

  describe '.new' do
    it 'defaults a user_balance is not provided' do
      presenter = VirtualCurrencyPresenter.new(virtual_currency: stub)
      presenter.user_balance.should == 0
    end

    it 'raises when a virtual currency is not provided' do
      expect {
        presenter = VirtualCurrencyPresenter.new(user_balance: 1.0)
      }.to raise_error(KeyError, 'key not found: :virtual_currency')
    end
  end

  describe '#user_balance_currency' do
    it 'returns the balance passed in * the currencies exchange rate' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.35, virtual_currency: stub(exchange_rate: 100))
      presenter.user_balance_currency.should === '135'
    end
  end

  describe '#currency_name' do
    it 'returns the name of the provided currency' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.0, virtual_currency: stub(name: 'Plonk Points'))
      presenter.currency_name.should == 'Plonk Points'
    end
  end

  describe '#id' do
    it 'returns the id of the provided virtual currency' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.0, virtual_currency: stub(id: 143))
      presenter.id.should == 143
    end
  end
end
