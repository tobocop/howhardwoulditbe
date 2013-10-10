require 'spec_helper'

describe Plink::RegistrationLinkMappingService do
  let(:affiliate) { create_affiliate }
  let(:campaign) { create_campaign(campaign_hash: 'fordeprication') }
  let(:landing_page) { create_landing_page(name: 'stuff') }
  let!(:registration_link) {
    create_registration_link(
      affiliate_id: affiliate.id,
      campaign_id: campaign.id,
      landing_page_records: [landing_page]
    )
  }

  before do
    create_registration_link_mapping(affiliate_id: affiliate.id, campaign_id: campaign.id, registration_link_id: registration_link.id)
  end

  describe'.get_registration_link_by_affiliate_id_and_campaign_hash' do
    it 'returns a registration link if a mapping exists for the campaign_hash and affiliate_id' do
      link = Plink::RegistrationLinkMappingService.get_registration_link_by_affiliate_id_and_campaign_hash(affiliate.id, campaign.campaign_hash)
      link.should == registration_link
    end

    it 'looks up the campaign_id by the campaign_hash' do
      Plink::EventService.any_instance.should_receive(:get_campaign_id).with('fordeprication') { 4 }

      Plink::RegistrationLinkMappingService.get_registration_link_by_affiliate_id_and_campaign_hash(affiliate.id, campaign.campaign_hash)
    end

    it 'returns false if no mapping is found' do
      Plink::RegistrationLinkMappingService.get_registration_link_by_affiliate_id_and_campaign_hash(1, 'not gonna happen').should be_false
    end
  end
end
