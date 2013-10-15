module Plink
  class RegistrationFlow

    attr_reader :registration_link_record, :landing_page_id, :landing_page_partial,
      :share_flow, :share_page_id, :share_page_partial

    def initialize(registration_link_record)
      @registration_link_record = registration_link_record
      landing_page = @registration_link_record.landing_page_records.sample
      @landing_page_id = landing_page.id
      @landing_page_partial = landing_page.partial_path

      @share_flow = @registration_link_record.share_flow?
      if @share_flow
        share_page = @registration_link_record.share_page_records.sample
        @share_page_id = share_page.id
        @share_page_partial = share_page.partial_path
      end
    end

    delegate :affiliate_id, :campaign_id, :live?, :mobile_detection_on?, :share_flow?,
      to: :registration_link_record
  end
end
