require 'spec_helper'

describe Plink::User do
  let(:user_attributes) do
    {
      id: 123,
      first_name: 'George',
      email: 'test@test.com',
      avatar_thumbnail_url: 'www.example.com/some_avatar',
      salt: 'angelinajolie',
      password_hash: 'somehashything'
    }
  end

  before do
    @virtual_currency = create_virtual_currency
  end

  it 'should return the data values it is initialized with' do

    user = Plink::User.new(
      new_user: false,
      user_record: create_user(user_attributes)
    )

    wallet = create_wallet(user_id: user.id)
    create_open_wallet_item(wallet_id: wallet.id)
    create_locked_wallet_item(wallet_id: wallet.id)

    user.id.should == 123
    user.new_user?.should be_false
    user.errors.should == []
    user.first_name.should == 'George'
    user.is_subscribed.should == true
    user.email.should == 'test@test.com'
    user.current_balance.should == 0
    user.lifetime_balance.should == 0
    user.can_redeem?.should == false
    user.wallet.id.should == wallet.id
    user.avatar_thumbnail_url.should == 'www.example.com/some_avatar'
    user.salt.should == 'angelinajolie'
    user.password_hash.should == 'somehashything'
    user.primary_virtual_currency_id.should == @virtual_currency.id
    user.avatar_thumbnail_url?.should be_true
    user.wallet.open_wallet_items.size.should == 1
    user.open_wallet_item.should be
    user.should respond_to(:update_attributes)
  end

  describe 'valid?' do
    it 'returns true when there are no errors' do
      user = Plink::User.new(
        new_user: false,
        user_record: create_user(user_attributes),
        errors: mock(:errors, empty?: true)
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
end