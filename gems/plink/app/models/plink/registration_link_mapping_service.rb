module Plink
  class RegistrationLinkMappingService
    def self.get_registration_link_by_affiliate_id_and_campaign_hash(affiliate_id, campaign_hash)
      campaign_id = Plink::EventService.new.get_campaign_id(campaign_hash)

      mapping = Plink::RegistrationLinkMappingRecord
        .where(affiliate_id: affiliate_id)
        .where(campaign_id: campaign_id)
        .first
      
      mapping ? mapping.registration_link_record : false
    end
  end
end
