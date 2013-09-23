require 'spec_helper'

describe Plink::CampaignRecord do
  let(:valid_params) {
    {
      name: 'Campaign Name',
      media_type: 'My type',
      creative: 'A creative description',
      is_incent: false,
      start_date: 1.day.ago,
      end_date: 1.day.from_now,
      campaign_hash: 'DERP'
    }
  }

  subject { Plink::CampaignRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::CampaignRecord.create(valid_params).should be_persisted
  end

  it 'is invalid without a name' do
    campaign = Plink::CampaignRecord.new
    campaign.should_not be_valid
    campaign.should have(1).error_on(:name)
  end

  describe 'by_campaign_hash' do

    before do
      @expected = create_campaign(campaign_hash: 'NINJAS')
    end

    it 'returns a CampaignRecord by a campaign hash' do
      campaign = Plink::CampaignRecord.for_campaign_hash('NINJAS')
      campaign.id.should == @expected.id
    end
  end

end
