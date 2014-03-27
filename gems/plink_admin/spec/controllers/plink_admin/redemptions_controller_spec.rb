require 'spec_helper'

describe PlinkAdmin::RedemptionsController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'POST create' do
    let(:user) { double(Plink::User, id: 4, current_balance: 9.23, first_name: 'bobby', email: 'something@test.com') }
    let(:user_service) { double(Plink::UserService, find_by_id: user) }
    let(:reward_redemption_service) { double(Plink::RewardRedemptionService, redeem: true) }
    let(:redemption_record) { double(Plink::RedemptionRecord, is_pending: true, sent_on: nil) }
    let(:redemption_records) { [redemption_record, redemption_record] }

    before do
      Plink::UserService.stub(:new).and_return(user_service)
      Plink::RewardRedemptionService.stub(:new).and_return(reward_redemption_service)
      Plink::RedemptionRecord.stub(:where).and_return(redemption_records)


      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'looks up the user' do
      Plink::UserService.should_receive(:new).with().and_return(user_service)
      user_service.should_receive(:find_by_id).with('4').and_return(user)

      post :create, {user_id: 4, reward_amount_id: 8}
    end

    it 'attempts to redeem for a user' do
      Plink::RewardRedemptionService.should_receive(:new).with(
        user_id: 4,
        reward_amount_id: '8',
        user_balance: 9.23,
        first_name: 'bobby',
        email: 'something@test.com'
      ).and_return(reward_redemption_service)
      reward_redemption_service.should_receive(:redeem).with()

      post :create, {user_id: 4, reward_amount_id: 8}
    end

    context 'when the redemption was successful' do
      it 'looks up the users last redemption' do
        Plink::RedemptionRecord.should_receive(:where).with(userID: 4).and_return(redemption_records)
        redemption_records.should_receive(:last).and_return(redemption_record)

        post :create, {user_id: 4, reward_amount_id: 8}
      end

      it 'redirects the user to the users page' do
        post :create, {user_id: 4, reward_amount_id: 8}

        response.should redirect_to '/users/4/edit'
      end

      context 'when the redemption is pending' do
        it 'sets the flash notice to notify the admin' do
          post :create, {user_id: 4, reward_amount_id: 8}

          flash[:notice].should == 'Redemption pending'
        end
      end

      context 'when the redemption is sent' do
        it 'sets the flash notice to notify the admin' do
          redemption_record.stub(:is_pending).and_return(false)
          redemption_record.stub(:sent_on).and_return(Time.zone.now)

          post :create, {user_id: 4, reward_amount_id: 8}

          flash[:notice].should == 'Redemption sent'
        end
      end
    end

    context 'when the redemption was not' do
      before do
        reward_redemption_service.stub(:redeem).and_return(false)
        post :create, {user_id: 4, reward_amount_id: 8}
      end

      it 'redirects the user to the users page' do
        response.should redirect_to '/users/4/edit'
      end

      it 'sets the flash notice to notify the admin' do
        flash[:notice].should == 'Redemption not sent. User does not have enough points or Tango is down.'
      end
    end
  end
end
