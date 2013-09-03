require 'spec_helper'

describe Plink::TangoRedemptionLimitRecord do

  let!(:user) {
    user = create_user(email: 'zaphod@example.com')
    create_redemption(user_id: user.id, is_pending: false, sent_on: 1.hour.ago)
    create_tango_tracking(user_id: user.id)
    user
  }
  subject(:tango_redemption_limit_record) { Plink::TangoRedemptionLimitRecord.where(userID: user.id).first }

  it 'returns the user_id' do
    tango_redemption_limit_record.user_id.should == user.id
  end

  it 'returns the value of the hold redemptions flag' do
    tango_redemption_limit_record.hold_redemptions.should_not be_true
  end

  it 'returns the number of redemptions' do
    tango_redemption_limit_record.redemption_count.should == 1
  end

  it 'returns the amount the user has redeemed in the past 24 hours' do
    tango_redemption_limit_record.redeemed_in_past_24_hours.should == 15
  end

end