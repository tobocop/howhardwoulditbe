require 'spec_helper'

describe Plink::AwardTypeRecord do

  let(:valid_params) {
    {
      award_code: 'ASD',
      award_display_name: 'Awesome Award',
      award_type: 'cool',
      is_active: true,
      dollar_amount: 1,
      email_message: 'message'
    }
  }

  subject { Plink::AwardTypeRecord.new(valid_params) }

  it 'can be persisted' do
    Plink::AwardTypeRecord.create(valid_params).should be_persisted
  end

  describe '.incented_affiliate_award_type_id' do
    it 'returns the id of the award record with type = incentivizedAffiliateID' do
      other_award_type_record = create_award_type(award_code: 'something_different')
      incented_award_type_record = create_award_type(award_code: 'incentivizedAffiliateID')

      incented_affiliate_award_type_id = Plink::AwardTypeRecord.incented_affiliate_award_type_id

      incented_affiliate_award_type_id.should == incented_award_type_record.id
      incented_affiliate_award_type_id.should_not == other_award_type_record.id
    end
  end

  describe '.referral_bonus_award_type_id' do
    it 'returns the id of the award record with type = friendReferral' do
      other_award_type_record = create_award_type(award_code: 'something_different')
      referral_award_type_record = create_award_type(award_code: 'friendReferral')

      referral_bonus_award_type_id = Plink::AwardTypeRecord.referral_bonus_award_type_id

      referral_bonus_award_type_id.should == referral_award_type_record.id
      referral_bonus_award_type_id.should_not == other_award_type_record.id
    end
  end
end
