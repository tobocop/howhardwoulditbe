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

  describe 'status' do
    it 'returns inactive if requires_reverification is true' do
      account = Plink::IntuitAccount.new(default_attrs)
      account.status.should == 'Inactive'
    end

    it 'returns active if requires_reverification is false' do
      account = Plink::IntuitAccount.new(default_attrs.merge(requires_reverification: false))
      account.status.should == 'Active'
    end
  end
end
