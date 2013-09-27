require 'spec_helper'

describe Plink::UserRecord do
  subject(:user_record) { new_user }

  it { should allow_mass_assignment_of(:avatar_thumbnail_url) }
  it { should allow_mass_assignment_of(:birthday) }
  it { should allow_mass_assignment_of(:city) }
  it { should allow_mass_assignment_of(:daily_contest_reminder) }
  it { should allow_mass_assignment_of(:email) }
  it { should allow_mass_assignment_of(:first_name) }
  it { should allow_mass_assignment_of(:is_male) }
  it { should allow_mass_assignment_of(:hold_redemptions) }
  it { should allow_mass_assignment_of(:ip) }
  it { should allow_mass_assignment_of(:password_hash) }
  it { should allow_mass_assignment_of(:provider) }
  it { should allow_mass_assignment_of(:salt) }
  it { should allow_mass_assignment_of(:state) }
  it { should allow_mass_assignment_of(:username) }
  it { should allow_mass_assignment_of(:zip) }

  it_should_behave_like(:legacy_timestamps)

  let(:valid_params) {
    {
      avatar_thumbnail_url: 'http://example.com/image.png',
      birthday: 1.day.ago,
      city: 'Denver',
      daily_contest_reminder: true,
      email: 'bob@example.com',
      first_name: 'jerry',
      is_male: true,
      hold_redemptions: true,
      ip: '127.0.0.1',
      password_hash: 'D7913D231B862AEAD93FADAFB90A90E1A599F0FC08851414FD69C473242DAABD4E6DBD978FBEC1B33995CD2DA58DD1FEA660369E6AE962007162721E9C195192', # password: AplaiNTextstrIng55
      provider: 'twitter',
      salt: '6BA943B9-E9E3-8E84-4EDCA75EE2ABA2A5',
      state: 'Colorado',
      username: 'bobby tables',
      zip: '80204'
    }
  }

  it 'can be persisted' do
    Plink::UserRecord.create(valid_params).should be_persisted
  end

  it 'provides a better interface to the legacy field names' do
    user = new_user(is_subscribed: true)

    user.is_subscribed.should == true
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password_hash) }
    it { should validate_presence_of(:salt) }

    it 'ensures first name must only be alphabetical letters, numbers, dashes, underscores, or spaces' do
      user_record.first_name = "asb2"
      user_record.should be_valid

      user_record.first_name = "asb;"
      user_record.should_not be_valid
      user_record.should have(1).error_on(:first_name)

      user_record.first_name = '_hunter'
      user_record.should be_valid

      user_record.first_name = '-hunter'
      user_record.should be_valid

      user_record.first_name = 'banana hamrick'
      user_record.should be_valid
    end

    it 'validates the format of the email address' do
      user_record.email = 'foo'
      user_record.should_not be_valid
      user_record.should have(1).error_on(:email)

      user_record.email = 'foo@'
      user_record.should_not be_valid
      user_record.should have(1).error_on(:email)

      user_record.email = 'foo@example'
      user_record.should_not be_valid
      user_record.should have(1).error_on(:email)

      user_record.email = 'foo@example.'
      user_record.should_not be_valid
      user_record.should have(1).error_on(:email)

      user_record.email = 'foo@example.c'
      user_record.should be_valid
    end

    it 'validates new password' do
      user_record.new_password = 'foo'
      user_record.should_not be_valid
      user_record.should have(1).error_on(:new_password)

      user_record.new_password = 'foobar'
      user_record.new_password_confirmation = 'foobee'
      user_record.should_not be_valid
      user_record.should have(1).error_on(:new_password)
    end

    it 'does not allow emails to be duplicates' do
      other_user = new_user
      other_user.email = user_record.email
      other_user.save!

      user_record.should_not be_valid
      user_record.should have(1).error_on(:email)
    end

    it 'validates that the provider is facebook, twitter, or organic' do
      user_record.provider = 'other'
      user_record.should_not be_valid

      user_record.provider = 'facebook'
      user_record.should be_valid

      user_record.provider = 'twitter'
      user_record.should be_valid

      user_record.provider = 'organic'
      user_record.should be_valid
    end
  end

  it 'has a primary virtual currency' do
    user_record.primary_virtual_currency = create_virtual_currency
    user_record.save!

    user_record.primary_virtual_currency.should be
  end

  it 'returns the primary virtrual currencies id' do
    currency = create_virtual_currency
    user_record.primary_virtual_currency = currency
    user_record.primary_virtual_currency_id.should == currency.id
  end

  it 'sets the virtual currency to the default Plink Points currency' do
    plink_point_currency = create_virtual_currency
    Plink::VirtualCurrency.stub(:default) { plink_point_currency }
    user_record.save!

    user_record.primary_virtual_currency.should == plink_point_currency
  end

  it 'has wallet items' do
    user_record.save!
    user_record.wallet_item_records.length.should == 0
    wallet = create_wallet(user_id: user_record.id)
    wallet_item = create_locked_wallet_item(wallet_id: wallet.id)
    user_record.wallet_item_records(true).length == 1
  end

  it 'has an empty wallet item' do
    user_record.save!
    wallet = create_wallet(user_id: user_record.id)
    wallet_item = create_open_wallet_item(wallet_id: wallet.id)
    user_record.open_wallet_item.should == wallet_item
  end

  it 'returns nil when no wallet items are empty' do
    user_record.save!
    wallet = create_wallet(user_id: user_record.id)
    wallet_item = create_locked_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: 123)
    user_record.open_wallet_item.should == nil
  end

  describe 'named scopes' do
    describe '.users_with_qualifying_transactions' do
      let(:users_with_qualifying_transactions) { Plink::UserRecord.users_with_qualifying_transactions }
      it 'returns users who have a qualifying transaction' do
        qualifying_user = create_user
        create_qualifying_award(user_id: qualifying_user.id)

        users_with_qualifying_transactions.should include qualifying_user
      end

      it 'does not return users who do not have a qualifying transaction' do
        non_qualifying_user = create_user
        users_with_qualifying_transactions.should_not include non_qualifying_user
      end
    end
  end

  describe '.user_ids_with_qualifying_transactions' do
    let(:user_ids_with_qualifying_transactions) { Plink::UserRecord.user_ids_with_qualifying_transactions }
    it 'returns users who have a qualifying transaction' do
      qualifying_user = create_user
      create_qualifying_award(user_id: qualifying_user.id)

      user_ids_with_qualifying_transactions.should include qualifying_user.id
    end

    it 'does not return users who do not have a qualifying transaction' do
      non_qualifying_user = create_user
      user_ids_with_qualifying_transactions.should_not include non_qualifying_user.id
    end
  end


  describe '.find_by_email' do
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

  describe '#currency_balance' do
    it 'returns the users balance of dollars in currency' do
      user = create_user
      user.currency_balance.should == 0
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
      double_password = double(:password, hashed_value: 'abcdefgh', salt: '12345678')
      Plink::Password.stub(:new).with(unhashed_password: 'abc1234').and_return(double_password)

      user_record.new_password = 'abc1234'
      user_record.new_password_confirmation = 'abc1234'
      user_record.save

      user_record.password_hash.should == 'abcdefgh'
      user_record.salt.should == '12345678'
    end

    it 'does not change the current password if it is invalid' do
      old_user_password_hash = user_record.password_hash

      user_record.new_password = 'abc'
      user_record.save

      user_record.password_hash.should == old_user_password_hash
    end
  end

  describe '#opt_in_to_daily_contest_reminders!' do
    let(:user) { create_user }

    it 'updates the user\'s daily contest reminder setting to true' do
      user.opt_in_to_daily_contest_reminders!

      user.daily_contest_reminder.should be_true
    end

    it 'changes the opt in even if the user is invalid' do
      user.update_attribute(:first_name, nil)
      user.should_not be_valid
      user.daily_contest_reminder.should be_nil

      user.opt_in_to_daily_contest_reminders!

      user.should_not be_valid
      user.daily_contest_reminder.should be_true
    end

    it 'sets the value from the optional boolean parameter' do
      user.opt_in_to_daily_contest_reminders!(false)

      user.daily_contest_reminder.should be_false
    end

    it 'raises an exception if the optional parameter is not a boolean' do
      expect {
        user.opt_in_to_daily_contest_reminders!('stuff')
      }.to raise_error ArgumentError
    end
  end
end
