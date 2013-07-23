require 'spec_helper'

describe VirtualCurrencyPresenter do

  describe '.new' do
    it 'raises when a virtual currency is not provided' do
      expect {
        presenter = VirtualCurrencyPresenter.new(user_balance: 1.0)
      }.to raise_error(KeyError, 'key not found: :virtual_currency')
    end
  end

  describe '#subdomain' do
    it 'returns the subdomain of the virtual currency' do
      presenter = VirtualCurrencyPresenter.new(virtual_currency: stub(subdomain: 'www'))
      presenter.subdomain.should == 'www'
    end
  end

  describe '#amount_in_currency' do
    it 'returns the given amount * the currency\'s exchange rate' do
      presenter = VirtualCurrencyPresenter.new(virtual_currency: stub(exchange_rate: 100))
      presenter.amount_in_currency(1.35).should === '135'
    end

    it 'returns 0 if nil amount is given' do
      presenter = VirtualCurrencyPresenter.new(virtual_currency: stub(exchange_rate: 100))
      presenter.amount_in_currency(nil).should === 0
    end
  end

  describe '#currency_name' do
    it 'returns the name of the provided currency' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.0, virtual_currency: stub(name: 'Plonk Points'))
      presenter.currency_name.should == 'Plonk Points'
    end
  end

  describe '#exchange_rate' do
    it 'returns the exchange rate of the provided currency' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.0, virtual_currency: stub(exchange_rate: 100, name: 'Plonk Points'))
      presenter.exchange_rate.should == 100
    end
  end

  describe '#id' do
    it 'returns the id of the provided virtual currency' do
      presenter = VirtualCurrencyPresenter.new(user_balance: 1.0, virtual_currency: stub(id: 143))
      presenter.id.should == 143
    end
  end
end
