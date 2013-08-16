require 'spec_helper'

describe Plink::UserCreationService do
  let (:valid_params) {{
      email: 'test@test.com',
      first_name: 'derp',
      password_hash: 'asd',
      salt: 'asd',
      avatar_thumbnail_url: 'http://www.google.com/logo.png',
      provider: 'organic'
  }}

  describe 'initialize' do
    it 'requires an email' do
      expect {
        Plink::UserCreationService.new(valid_params.except(:email))
      }.to raise_exception(KeyError, 'key not found: :email')
    end

    it 'requires a first name' do
      expect {
        Plink::UserCreationService.new(valid_params.except(:first_name))
      }.to raise_exception(KeyError, 'key not found: :first_name')
    end

    it 'requires a password_hash' do
      expect {
        Plink::UserCreationService.new(valid_params.except(:password_hash))
      }.to raise_exception(KeyError, 'key not found: :password_hash')
    end

    it 'requires a salt' do
      expect {
        Plink::UserCreationService.new(valid_params.except(:salt))
      }.to raise_exception(KeyError, 'key not found: :salt')
    end

    it 'requires a provider' do
      expect {
        Plink::UserCreationService.new(valid_params.except(:provider))
      }.to raise_exception(KeyError, 'key not found: :provider')
    end

    it 'can be initialized with an avatar_thumbnail_url' do
      service = Plink::UserCreationService.new(valid_params)
      service.avatar_thumbnail_url.should == 'http://www.google.com/logo.png'
    end

    it 'creates a user object' do
      Plink::UserRecord.should_receive(:new).with(valid_params)
      service = Plink::UserCreationService.new(valid_params)
    end
  end

  describe 'create_user' do
    let(:user) { stub(id:42, save:true, primary_virtual_currency_id: 54) }

    before do
      Plink::UserRecord.stub(:new) { user }
      Plink::WalletCreationService.stub(:new) { stub(create_for_user_id: true) }
    end

    it 'saves a user record' do
      Plink::UserRecord.should_receive(:new).with(valid_params) { user }
      Plink::UserCreationService.new(valid_params).create_user
    end

    it 'creates the users wallet' do
      wallet_creation_service = stub
      Plink::WalletCreationService.should_receive(:new).with(user_id: user.id) { wallet_creation_service  }
      wallet_creation_service.should_receive(:create_for_user_id).with(number_of_locked_slots: 2)
      Plink::UserCreationService.new(valid_params).create_user
    end

    it 'creates a users virtual currency record' do
      Plink::UsersVirtualCurrencyRecord.should_receive(:create).with(user_id: user.id, start_date: Time.zone.today, virtual_currency_id: user.primary_virtual_currency_id)
      Plink::UserCreationService.new(valid_params).create_user
    end

    it 'returns the created user' do
      created_user = Plink::UserCreationService.new(valid_params).create_user
      created_user.id.should == user.id
      created_user.should be_instance_of Plink::User
      created_user.new_user?.should be_true
    end
  end

  describe 'valid' do
    it 'returns true if the user is valid' do
      user = stub(valid?: true)
      Plink::UserRecord.stub(:new) {user}
      Plink::UserCreationService.new(valid_params).valid?.should be_true
    end

    it 'returns false if the user is not valid' do
      user = stub(valid?: false)
      Plink::UserRecord.stub(:new) {user}
      Plink::UserCreationService.new(valid_params).valid?.should be_false
    end
  end

  describe 'errors' do
    it 'exposes errors if the user is not valid' do
      user = stub(first_name:nil, valid?: false, errors: [])
      Plink::UserRecord.stub(:new) {user}
      user_creation_service = Plink::UserCreationService.new(valid_params)
      user_creation_service.valid?
      user_creation_service.errors.should == []
    end
  end

  describe 'id' do
    it 'returns the id of the user' do
      user = stub(id:243)
      Plink::UserRecord.stub(:new) {user}
      user_creation_service = Plink::UserCreationService.new(valid_params)
      user_creation_service.user_id.should == 243
    end
  end
end
