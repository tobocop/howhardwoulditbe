require 'spec_helper'

describe Plink::QualifyingAwardRecord do

  let(:valid_params) {
    {
      currency_award_amount: 13,
      dollar_award_amount: 0.13,
      user_id: 13,
      users_virtual_currency_id: 2,
      virtual_currency_id: 2,
      advertiser_id: 23,
      is_active: true,
      is_successful: true,
      is_notification_successful: true
    }
  }

  subject { new_qualifying_award(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::QualifyingAwardRecord.create(valid_params).should be_persisted
  end

  context 'named scopes' do
    describe '.find_successful_by_user_id' do
      let(:user) { create_user(email: 'piglet@example.com') }
      let(:another_user) { create_user(email: 'pooh@example.com') }
      let!(:expected_qualifying_award) { create_qualifying_award(user_id: user.id, is_successful: true) }

      before :each do
        create_qualifying_award(user_id: user.id, is_successful: false)
      end

      it 'returns successful qualifying awards by user_id' do
        qualifying_awards = Plink::QualifyingAwardRecord.find_successful_by_user_id(user.id)
        qualifying_awards.size.should == 1
        qualifying_awards.first.id.should == expected_qualifying_award.id
        qualifying_awards.first.user_id.should == user.id
      end
    end

  end
end
