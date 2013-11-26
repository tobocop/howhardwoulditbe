require 'spec_helper'

describe Plink::IntuitAccount do
  let(:default_attrs) {
    {
      account_name: 'account of the bank of the firstmerica',
      account_number_last_four: 4512,
      bank_name: 'Bank of firstmerica',
      requires_reverification: true,
      users_institution_id: 4
    }
  }

  it 'returns the data values it is initialized with' do
    account = Plink::IntuitAccount.new(default_attrs)
    account.account_name.should == 'account of the bank of the firstmerica 4512'
    account.bank_name.should == 'Bank of firstmerica'
    account.users_institution_id.should == 4
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
