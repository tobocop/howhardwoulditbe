require 'spec_helper'

describe 'reward:send_reward_notifications' do
  include_context 'rake'
  let!(:virtual_currency) { create_virtual_currency(subdomain: 'www') }
  let!(:user_with_no_awards) { create_user }
  let!(:user_with_three_awards) { create_user(email: 'spelling@joesspellingacademy.com') }
  let!(:award_type) { create_award_type(award_type: 'Bananas are awesome') }
  let!(:advertiser) { create_advertiser }
  let(:valid_award_params) {
    {
      user_id: user_with_three_awards.id,
      is_notification_successful: false,
      is_active: true,
      is_successful: true,
      virtual_currency_id: virtual_currency.id
    }
  }
  let!(:free_award) {
    create_free_award(
      valid_award_params.merge(
        award_type_id: award_type.id,
        dollar_award_amount: 1.0
      )
    )
  }
  let!(:qualifying_award) {
    create_qualifying_award(
      valid_award_params.merge(
        advertiser_id: advertiser.id,
        dollar_award_amount: 2.0
      )
    )
  }
  let!(:non_qualifying_award) {
    create_non_qualifying_award(
      valid_award_params.merge(
        advertiser_id: advertiser.id,
        dollar_award_amount: 3.0
      )
    )
  }

  it 'send a delayed email to users with an auto login token who have pending rewards' do
    reward_mail = double(deliver: true)
    delay = double(reward_notification_email: reward_mail)

    AutoLoginService.should_receive(:generate_token)
      .with(user_with_three_awards.id)
      .and_return('my_token')

    RewardMailer.should_receive(:delay).and_return(delay)

    delay.should_receive(:reward_notification_email) do |args|
      args[:email].should == 'spelling@joesspellingacademy.com'
      args[:rewards].map(&:currency_award_amount).should =~ ['100', '200', '300']
      args[:user_currency_balance].should == '600'
      args[:user_token].should == 'my_token'
      reward_mail
    end

    subject.invoke
  end

  it 'updates rewards to set is_notification_successful to true that were processed' do
    Plink::AwardRecord.where('isNotificationSuccessful = ?', 0).length.should == 3

    Plink::FreeAwardRecord.any_instance.should_receive(:update_attributes)
      .with(is_notification_successful: true)
      .and_call_original
    Plink::QualifyingAwardRecord.any_instance.should_receive(:update_attributes)
      .with(is_notification_successful: true)
      .and_call_original
    Plink::NonQualifyingAwardRecord.any_instance.should_receive(:update_attributes)
      .with(is_notification_successful: true)
      .and_call_original

    subject.invoke

    Plink::AwardRecord.where('isNotificationSuccessful = ?', 0).length.should == 0
  end

  it "gets distinct user id's  with awards pending notification" do
    award_select = double(:plink_point_awards_pending_notification)
    Plink::AwardRecord.should_receive('select').with('distinct userID')
      .and_return(award_select)
    award_select.should_receive(:plink_point_awards_pending_notification)
      .and_return([])

    subject.invoke
  end
end
