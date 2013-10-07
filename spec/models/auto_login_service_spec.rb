require 'spec_helper'

describe AutoLoginService do
  describe '.find_by_user_token' do
    let(:user) { create_user }

    it 'returns nil if the user token does not exist' do
      AutoLoginService.find_by_user_token('12345AdC').should be_nil
    end

    it 'returns a user if the user token exists' do
      user_auto_login_record = create_user_auto_login(user_id: user.id)

      AutoLoginService.find_by_user_token(user_auto_login_record.user_token).id.should == user.id
    end

    it 'returns nil if the user token is expired' do
      user_auto_login_record = create_user_auto_login(user_id: user.id, expires_at: 2.days.ago)

      AutoLoginService.find_by_user_token(user_auto_login_record.user_token).should be_nil
    end
  end
end
