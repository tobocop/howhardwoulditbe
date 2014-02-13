require 'spec_helper'

describe Plink::TangoRedemptionLimitService do

  describe '#user_over_redemption_limit?' do

    let(:user) { new_user(id: 1, email: 'walter.mitty@example.com') }
    subject(:tango_redemption_limit_service) { Plink::TangoRedemptionLimitService.new(user.id) }

    context 'when flagged to hold redemptions' do
      let(:tango_redemption_limit_record) { new_tango_redemption_limit(
        user_id: user.id,
        hold_redemptions: true,
        redemption_count: 0,
        redeemed_in_past_24_hours: 0
      ) }

      it 'returns true if a user has already been flagged to hold redemptions' do
        Plink::TangoRedemptionLimitRecord.stub(:where).and_return([tango_redemption_limit_record])

        tango_redemption_limit_service.user_over_redemption_limit?.should be_true
      end
    end

    context 'when not flagged to hold redemptions' do
      let(:tango_redemption_limit_record) { new_tango_redemption_limit(
        user_id: user.id,
        hold_redemptions: false,
        redemption_count: 0,
        redeemed_in_past_24_hours: 0
      ) }

      it 'returns false if a user has not been flagged to hold redemptions' do
        Plink::TangoRedemptionLimitRecord.stub(:where).and_return([tango_redemption_limit_record])

        tango_redemption_limit_service.user_over_redemption_limit?.should be_false
      end
    end

    context 'when under the redemption limit' do

      let(:tango_redemption_limit_record) { new_tango_redemption_limit }

      it 'returns false' do
        Plink::TangoRedemptionLimitRecord.stub(:where).and_return([tango_redemption_limit_record])

        tango_redemption_limit_service.user_over_redemption_limit?.should be_false
      end

    end

    context 'when over the redemption limit, but currently unflagged' do
      let(:tango_redemption_limit_record) { new_tango_redemption_limit(
        user_id: user.id,
        hold_redemptions: nil,
        redemption_count: 11,
        redeemed_in_past_24_hours: 101
      ) }

      it 'returns true' do
        Plink::TangoRedemptionLimitRecord.stub(:where).and_return([tango_redemption_limit_record])
        Plink::UserRecord.stub(:find).and_return(user)
        Plink::UserRecord.stub(:save!).and_return(true)

        tango_redemption_limit_service.user_over_redemption_limit?.should be_true
      end


      it 'sets the user\'s hold redemption flag' do
        Plink::TangoRedemptionLimitRecord.stub(:where).and_return([tango_redemption_limit_record])
        Plink::UserRecord.stub(:find).and_return(user)
        Plink::UserRecord.stub(:save!).and_return(true)

        tango_redemption_limit_service.user_over_redemption_limit?.should be_true
      end

    end

    context 'when over the redemption limit and flagged as being over the redemption limit' do

      let(:tango_redemption_limit_record) { new_tango_redemption_limit(
        user_id: user.id,
        hold_redemptions: 1,
        redemption_count: 11,
        redeemed_in_past_24_hours: 101
      ) }

      it 'returns true if a user has already been flagged as over the redemption limit' do
        Plink::TangoRedemptionLimitRecord.stub(:where).and_return([tango_redemption_limit_record])

        tango_redemption_limit_service.user_over_redemption_limit?.should be_true
      end

    end

  end

end