require 'spec_helper'

describe Plink::AffiliateRecord do
  let(:valid_params) {
    {
      name: 'Created name',
      has_incented_card_registration: false,
      card_registration_dollar_award_amount: 1.34,
      has_incented_join: false,
      join_dollar_award_amount: 1.34,
      card_add_pixel: '<img src="http://example.com/image.png />',
      email_add_pixel: '<img src="http://example.com/image.png />',
      disclaimer_text: 'some disclaimer stuff'
    }
  }

  subject { Plink::AffiliateRecord.new(valid_params) }

  it 'can be persisted' do
    Plink::AffiliateRecord.create(valid_params).should be_persisted
  end

  it 'is invalid without a name' do
    affiliate = Plink::CampaignRecord.new
    affiliate.should_not be_valid
    affiliate.should have(1).error_on(:name)
  end
end
