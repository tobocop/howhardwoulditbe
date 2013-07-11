require 'spec_helper'

describe Plink::ActiveIntuitAccount do
  it 'should return the data values it is initialized with' do
    account = Plink::ActiveIntuitAccount.new(
      bank_name: 'Bank of firstmerica',
      account_name: 'account of the bank of the firstmerica',
      account_number_last_four: 4512
    )
    account.bank_name.should == 'Bank of firstmerica'
    account.account_name.should == 'account of the bank of the firstmerica 4512'
  end
end
