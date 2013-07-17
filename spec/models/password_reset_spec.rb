require 'spec_helper'

describe PasswordReset do
  describe '.build' do
    it 'creates a password reset' do
      expect {
        PasswordReset.build(user_id: 3)
      }.to change { PasswordReset.count }.by(1)
    end

    it 'generates a token' do
      SecureRandom.should_receive(:uuid).and_return('da-token')
      password_reset = PasswordReset.build(user_id: 3)
      password_reset.token.should == 'da-token'
    end

    it 'ensures that the token does not already exist' do
      PasswordReset.create(user_id: 2, token: 'da-token')

      SecureRandom.should_receive(:uuid).and_return('da-token', 'new-token')

      password_reset = PasswordReset.build(user_id: 3)
      password_reset.token.should == 'new-token'
    end
  end
end