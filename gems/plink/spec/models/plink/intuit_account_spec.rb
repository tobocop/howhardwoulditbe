require 'spec_helper'

describe Plink::IntuitAccount do
  let(:default_attrs) {
    {
      bank_name: 'Bank of firstmerica',
      account_name: 'account of the bank of the firstmerica',
      account_number_last_four: 4512,
      requires_reverification: true
    }
  }

  it 'returns the data values it is initialized with' do
    account = Plink::IntuitAccount.new(default_attrs)
    account.bank_name.should == 'Bank of firstmerica'
    account.account_name.should == 'account of the bank of the firstmerica 4512'
  end

  describe 'active?' do
    it 'returns true if requires_reverification is false' do
      account = Plink::IntuitAccount.new(default_attrs.merge(requires_reverification: false))
      account.active?.should be_true
    end

    it 'returns inactive if requires_reverification is true' do
      account = Plink::IntuitAccount.new(default_attrs)
      account.active?.should be_false
    end

  end

end
