require 'spec_helper'

describe Plink::CampaignRecord do
  let(:valid_params) {
    {
      campaign_hash: 'DERP'
    }
  }

  subject { Plink::CampaignRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::CampaignRecord.create(valid_params).should be_persisted
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