require 'spec_helper'

describe IntuitAccountType do

  describe '.AccountType' do
    it 'allows a type of CREDITCARD' do
      IntuitAccountType::AccountType('CREDITCARD').should == 'CREDITCARD'
    end

    it 'allows a type of CHECKING' do
      IntuitAccountType::AccountType('CHECKING').should == 'CHECKING'
    end

    it 'allows a type of debit' do
      IntuitAccountType::AccountType('debit').should == 'CHECKING'
    end

    it 'allows a case-insensitive valid account types' do
      IntuitAccountType::AccountType('CREDitCARD').should == 'CREDITCARD'
    end

    it 'disallows invalid account types' do
      IntuitAccountType::AccountType('junk').should == nil
    end

    it 'converts symbols' do
      IntuitAccountType::AccountType(:debit).should == 'CHECKING'
    end

    it 'does not raise an exception if given a nil account_type argument' do
      IntuitAccountType::AccountType(nil).should == nil
    end
  end
end
