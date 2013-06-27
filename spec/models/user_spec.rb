require 'spec_helper'

describe User do
  subject { new_user }

  it_should_behave_like(:legacy_timestamps)

  it 'be valid' do
    subject.should be_valid
  end

  it 'must have a first name' do
    subject.first_name = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:first_name)
  end

  it 'must have an email address' do
    subject.email = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:email)
  end

  it 'must have a password hash' do
    subject.password_hash = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:password_hash)
  end

  it 'must have a salt' do
    subject.salt = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:salt)
  end

  it 'does not allow emails to be duplicates' do
    other_user = new_user
    other_user.email = subject.email
    other_user.save!

    subject.should_not be_valid
    subject.should have(1).error_on(:email)
  end

  it 'allows assignment of avatar_thumbnail_url' do
    subject.update_attributes(avatar_thumbnail_url: 'test123')
    subject.avatar_thumbnail_url.should == 'test123'
  end

  it 'has a primary virtual currency' do
    subject.primary_virtual_currency = create_virtual_currency
    subject.save!

    subject.primary_virtual_currency.should be
  end

  it 'returns the primary virtrual currencies id' do
    currency = create_virtual_currency
    subject.primary_virtual_currency = currency
    subject.primary_virtual_currency_id.should == currency.id
  end

  it 'sets the virtual currency to the default Plink Points currency' do
    plink_point_currency = create_virtual_currency
    VirtualCurrency.stub(:default) { plink_point_currency }
    subject.save!

    subject.primary_virtual_currency.should == plink_point_currency
  end

  describe 'class methods' do
    it 'finds a user by their email address' do
      user = create_user
      User.find_by_email(user.email).should == user
    end
  end

  describe '#current_balance' do
    it 'returns the users balance of dollars' do
      user = create_user
      user.current_balance.should == 0
    end
  end
end