require 'spec_helper'

describe Plink::User do
  let(:user_attributes) do
    {
      avatar_thumbnail_url: 'www.example.com/some_avatar',
      birthday: 10.years.ago.to_date,
      daily_contest_reminder: false,
      email: 'test@test.com',
      first_name: 'George',
      id: 123,
      ip: '123.34.234.2',
      is_male: true,
      last_name: 'Kramer',
      password_hash: 'somehashything',
      provider: 'twitter',
      salt: 'angelinajolie',
      state: 'Derp',
      zip: 80204
    }
  end

  before do
    @virtual_currency = create_virtual_currency
  end

  it 'should return the data values it is initialized with' do
    SecureRandom.stub(:uuid).and_return('my-uuid')

    user = Plink::User.new(
      new_user: false,
      user_record: create_user(user_attributes)
    )

    wallet = create_wallet(user_id: user.id)
    create_open_wallet_item(wallet_id: wallet.id)
    create_locked_wallet_item(wallet_id: wallet.id)

    user.should respond_to(:update_attributes)
    user.avatar_thumbnail_url.should == 'www.example.com/some_avatar'
    user.avatar_thumbnail_url?.should be_true
    user.birthday.to_date.should == 10.years.ago.to_date
    user.can_redeem?.should == false
    user.current_balance.should == 0
    user.currency_balance.should == 0
    user.daily_contest_reminder.should be_false
    user.email.should == 'test@test.com'
    user.errors.should == []
    user.first_name.should == 'George'
    user.id.should == 123
    user.ip.should == '123.34.234.2'
    user.is_male.should be_true
    user.is_subscribed.should == true
    user.last_name.should == 'Kramer'
    user.login_token.should == '56F8F3993DB5C463ED63C67938C0864544DB6E693A84CBC84581B33D84D920DF'
    user.lifetime_balance.should == 0
    user.new_user?.should be_false
    user.open_wallet_item.should be
    user.password_hash.should == 'somehashything'
    user.primary_virtual_currency_id.should == @virtual_currency.id
    user.provider.should == 'twitter'
    user.salt.should == 'angelinajolie'
    user.state.should == 'Derp'
    user.unsubscribe_date.should be_nil
    user.wallet.id.should == wallet.id
    user.wallet.open_wallet_items.size.should == 1
    user.zip.should == 80204
  end

  describe 'valid?' do
    it 'returns true when there are no errors' do
      user = Plink::User.new(
        new_user: false,
        user_record: create_user(user_attributes),
        errors: double(:errors, empty?: true)
      )

      user.should be_valid
    end

    it 'returns false where there are errors' do
      user = Plink::User.new(
        new_user: false,
        user_record: create_user(user_attributes),
        errors: 'some errors'
      )

      user.should_not be_valid
    end
  end

  describe '#can_receive_plink_email?' do
    it 'returns false if the user is not subscribed' do
      user = Plink::User.new(
        new_user: false,
        user_record: create_user(user_attributes.merge(is_subscribed: false))
      )

      user.can_receive_plink_email?.should be_false
    end

    it 'returns false if the user is not a plink points user' do
      user_record = create_user(user_attributes)
      swagbucks = create_virtual_currency(subdomain: 'swagbucks')
      user_record.primary_virtual_currency = swagbucks
      user_record.save
      user = Plink::User.new(new_user: false, user_record: user_record)

      user.can_receive_plink_email?.should be_false
    end

    it 'returns true if the user is subscribed and earning plink points' do
      user = Plink::User.new(new_user: false, user_record: create_user(user_attributes))
      user.can_receive_plink_email?.should be_true
    end
  end
end
