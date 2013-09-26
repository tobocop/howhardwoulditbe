module Plink
  class RegistrationPath

    attr_reader :registration_link_record, :landing_page_partial, :landing_page_id

    def initialize(registration_link_record)
      @registration_link_record = registration_link_record
      landing_page = @registration_link_record.landing_page_records.sample
      @landing_page_partial = landing_page.partial_path
      @landing_page_id = landing_page.id
    end

    delegate :affiliate_id, :campaign_id, to: :registration_link_record

    def live?
      registration_link_record.live?
    end
  end
end
