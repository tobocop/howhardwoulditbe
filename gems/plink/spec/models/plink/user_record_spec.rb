require 'spec_helper'

describe Plink::UserRecord do
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
    subject.should have(2).error_on(:email)
  end

  it 'validates the format of the email address' do
    subject.email = 'foo'
    subject.should_not be_valid
    subject.should have(1).error_on(:email)

    subject.email = 'foo@'
    subject.should_not be_valid
    subject.should have(1).error_on(:email)

    subject.email = 'foo@example'
    subject.should_not be_valid
    subject.should have(1).error_on(:email)

    subject.email = 'foo@example.'
    subject.should_not be_valid
    subject.should have(1).error_on(:email)

    subject.email = 'foo@example.c'
    subject.should be_valid
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

  it 'validates new password' do
    subject.new_password = 'foo'
    subject.should_not be_valid
    subject.errors.full_messages.should == ['New password is too short (minimum is 6 characters)']

    subject.new_password = 'foobar'
    subject.new_password_confirmation = 'foobee'
    subject.should_not be_valid
    subject.errors.full_messages.should == ["New password doesn't match confirmation"]
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
    Plink::VirtualCurrency.stub(:default) { plink_point_currency }
    subject.save!

    subject.primary_virtual_currency.should == plink_point_currency
  end

  it 'has wallet items' do
    subject.save!
    subject.wallet_item_records.length.should == 0
    wallet = create_wallet(user_id: subject.id)
    wallet_item = create_locked_wallet_item(wallet_id: wallet.id)
    subject.wallet_item_records(true).length == 1
  end

  it 'has an empty wallet item' do
    subject.save!
    wallet = create_wallet(user_id: subject.id)
    wallet_item = create_open_wallet_item(wallet_id: wallet.id)
    subject.open_wallet_item.should == wallet_item
  end

  it 'returns nil when no wallet items are empty' do
    subject.save!
    wallet = create_wallet(user_id: subject.id)
    wallet_item = create_locked_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: 123)
    subject.open_wallet_item.should == nil
  end

  describe 'class methods' do
    it 'finds a user by their email address' do
      user = create_user
      Plink::UserRecord.find_by_email(user.email).should == user
    end
  end

  describe '#current_balance' do
    it 'returns the users balance of dollars' do
      user = create_user
      user.current_balance.should == 0
    end
  end

  describe '.find_by_id' do
    it 'returns the user with the given id' do
      user = create_user

      Plink::UserRecord.find_by_id(user.id).should == user
    end

    it 'returns nil if no user present' do
      Plink::UserRecord.find_by_id(333).should == nil
    end
  end

  describe '#lifetime_balance' do
    it 'returns the users lifetime balance in dollars' do
      user = create_user
      user.lifetime_balance.should == 0
    end
  end

  describe '#can_redeem?' do
    it 'returns whether or not the user can redeem for a reward' do
      user = create_user
      user.can_redeem?.should == false
    end
  end

  describe '#new_password=' do
    it 'changes the password to the hashed version of the new password if it is valid' do
      mock_password = mock(:password, hashed_value: 'abcdefgh', salt: '12345678')
      Plink::Password.stub(:new).with(unhashed_password: 'abc1234').and_return(mock_password)

      subject.new_password = 'abc1234'
      subject.new_password_confirmation = 'abc1234'
      subject.save

      subject.password_hash.should == 'abcdefgh'
      subject.salt.should == '12345678'
    end

    it 'does not change the current password if it is invalid' do
      old_user_password_hash = subject.password_hash

      subject.new_password = 'abc'
      subject.save

      subject.password_hash.should == old_user_password_hash
    end
  end
end
