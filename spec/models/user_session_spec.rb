require 'spec_helper'

describe UserSession do
  subject { UserSession.new }

  it 'is never persisted' do
    subject.persisted?.should_not be
  end

  it 'should not have a default email set' do
    subject.email.should_not be
  end

  it 'should have an email' do
    subject.email = 'test456@example.com'
    subject.email.should == 'test456@example.com'
  end

  it 'should set the email address on initialize' do
    user_session = UserSession.new(email: 'test123@example.com')
    user_session.email.should == 'test123@example.com'
  end

  it 'should set the password on initialize' do
    user_session = UserSession.new(password: 'test123')
    user_session.password.should == 'test123'
  end

  describe '#valid?' do

    before do
      user = stub(id: 0, salt: 'my-salt', password_hash: 'my-hash')
      User.stub(:find_by_email) { user }
    end

    let(:valid_options) { {email: 'test123@example.com', password: 'test123'} }
    it 'returns true on success' do
      user_session = UserSession.new(valid_options)
      password_object = stub(hashed_value: 'my-hash')
      Password.should_receive(:new).with(unhashed_password: 'test123', salt: 'my-salt') { password_object }
      user_session.should be_valid
    end

    it 'sets a user id when valid' do
      user = stub(salt: 'my-salt', password_hash: 'my-hash')
      User.stub(:find_by_email).with('test123@example.com') { user }
      Password.any_instance.stub(:hashed_value) { 'my-hash' }
      user_session = UserSession.new(valid_options)
      user_session.valid?
      user_session.user.should == user
    end

    it 'returns false when an error occurs' do
      User.stub(:find_by_email).with('test123@example.com') { nil }
      user_session = UserSession.new(valid_options)
      user_session.should_not be_valid
    end

    it 'sets an error for an empty password' do
      user_session = UserSession.new(valid_options.merge(password: ''))
      user_session.valid?
      user_session.errors.full_messages.join.should == 'Password can\'t be blank'
    end


    it 'sets an error for an empty email' do
      user_session = UserSession.new(valid_options.merge(email: ''))
      user_session.valid?
      user_session.errors.full_messages.join.should == 'Email can\'t be blank'
    end

    it 'it does not set user when invalid' do
      User.stub(:find_by_email).with('test123@example.com') { nil }
      user_session = UserSession.new(valid_options)
      user_session.valid?
      user_session.user.should_not be
    end

    let(:invalid_user_message) { 'Email or password is invalid' }

    it 'sets an error if it can\'t find the user' do
      User.stub(:find_by_email).with('test123@example.com') { nil }
      user_session = UserSession.new(valid_options)
      user_session.valid?
      user_session.errors.full_messages.join.should == invalid_user_message
    end

    it 'sets an error for an invalid password' do
      user = stub(password_hash: 'my-hash', salt: 'salt')
      User.stub(:find_by_email).with('test123@example.com') { user }
      user_session = UserSession.new(valid_options.merge(password: 'unmatched-password'))
      user_session.valid?
      user_session.errors.full_messages.join.should == invalid_user_message
    end
  end
end