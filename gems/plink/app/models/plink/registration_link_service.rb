module Plink
  class RegistrationLinkService

    def self.get_registration_path_by_registration_link_id(id)
      create_registration_path(Plink::RegistrationLinkRecord.find(id))
    end

  private
    
    def self.create_registration_path(registration_link_record)
      Plink::RegistrationPath.new(registration_link_record)
    end

  end
end
