require 'spec_helper'

describe Intuit::Request do
  let(:aggcat) { mock(Aggcat) }

  describe '#new' do
    it 'instantiates Aggcat' do
      Aggcat.should_receive(:scope).with(123)

      Intuit::Request.new(123)
    end
  end

  describe '#accounts' do
    before { aggcat.stub(:discover_and_add_accounts).and_return(true) }

    it 'calls discoverAndAddAccounts' do
      Aggcat.stub(:scope).and_return(aggcat)

      aggcat.should_receive(:discover_and_add_accounts).with(456, 'user', 'password')

      Intuit::Request.new(123).accounts(456, ['user', 'password'])
    end
  end

  describe '#respond_to_mfa' do
    before { aggcat.stub(:account_confirmation).and_return(true) }

    it 'calls institutions/#{institution_id}/logins' do
      Aggcat.stub(:scope).and_return(aggcat)

      aggcat.should_receive(:account_confirmation).with(456, 1, 2, 'my answer')

      Intuit::Request.new(123).respond_to_mfa(456, 1, 2, 'my answer')
    end
  end

  describe '#login_accounts' do
    before { aggcat.stub(:login_accounts).and_return(true) }

    it 'calls getLoginAccounts' do
      Aggcat.stub(:scope).and_return(aggcat)

      aggcat.should_receive(:login_accounts).with('1234123412341234')

      Intuit::Request.new(123).login_accounts('1234123412341234')
    end
  end
end
