require 'spec_helper'

describe SocialProfileService do
  describe '.get_users_social_profile' do
    let(:profile) { {user_id: 345, name: 'asd'}.to_json }
    let(:successful_user_info_response) { double(Gigya::UserInfoResponse, json: profile, successful?: true) }
    let(:failed_user_info_response) { double(Gigya::UserInfoResponse, json: profile, successful?: false) }
    let(:gigya_connection) { double(Gigya, get_user_info: successful_user_info_response) }

    before do
      SocialProfileService.stub(:gigya_connection).and_return(gigya_connection)
      Plink::UsersSocialProfileRecord.stub(:create)
    end

    it 'calls gigya to get the users social profile' do
      gigya_connection.should_receive(:get_user_info).with(345).and_return(successful_user_info_response)

      SocialProfileService.get_users_social_profile(345)
    end

    context 'when the call is successful' do
      it 'stores the social profile' do
        Plink::UsersSocialProfileRecord.should_receive(:create).with(user_id: 345, profile: profile)

        SocialProfileService.get_users_social_profile(345)
      end
    end

    context 'when the call is not successful' do
      before { gigya_connection.stub(get_user_info: failed_user_info_response) }

      it 'does not store the social profile' do
        Plink::UsersSocialProfileRecord.should_not_receive(:create)

        SocialProfileService.get_users_social_profile(345)
      end
    end
  end
end
