module PlinkAdmin
  module RegistrationLinkHelper
    def generate_registration_link_url(registration_link_id)
      plink_admin.registration_link_url(registration_link_id).gsub(/plink_admin\//, '')
    end

    def present_share_state(shared)
      if shared.nil?
        'No'
      elsif shared == true
        'Yes'
      else
        'Decline'
      end
    end

    def present_proportion(count, total)
      percentage = (BigDecimal.new(count) / total)
      rounded_percentage = percentage.round(5) * 100

      "#{number_with_precision(rounded_percentage, precision: 2)}%"
    end
  end
end
