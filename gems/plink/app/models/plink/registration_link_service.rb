module Plink
  class RegistrationLinkService

    def self.get_registration_flow_by_registration_link_id(id)
      new_registration_flow(Plink::RegistrationLinkRecord.find(id))
    end

  private

    def self.new_registration_flow(registration_link_record)
      Plink::RegistrationFlow.new(registration_link_record)
    end

  end
end
