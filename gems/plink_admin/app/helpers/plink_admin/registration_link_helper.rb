module PlinkAdmin
  module RegistrationLinkHelper
    def generate_registration_link_url(registration_link_id)
      registration_link_url(registration_link_id).gsub(/plink_admin\//, '')
    end
  end
end
