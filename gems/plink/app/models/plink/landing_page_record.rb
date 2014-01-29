module Plink
  class LandingPageRecord < ActiveRecord::Base

    self.table_name = 'landing_pages'

    has_many :registration_link_landing_page_records, class_name: 'Plink::RegistrationLinkLandingPageRecord', foreign_key: 'landing_page_id'
    has_many :registration_link_records, class_name: 'Plink::RegistrationLinkRecord', through: :registration_link_landing_page_records

    attr_accessible :background_image_url, :button_text_one, :cms, :detail_text_four, :detail_text_four_styles,
      :detail_text_one, :detail_text_one_styles, :detail_text_three, :detail_text_three_styles,
      :detail_text_two, :detail_text_two_styles, :header_text_one, :header_text_one_styles,
      :header_text_two, :header_text_two_styles, :how_plink_works_one_text_one, :how_plink_works_one_text_one_styles,
      :how_plink_works_one_text_three, :how_plink_works_one_text_three_styles, :how_plink_works_one_text_two,
      :how_plink_works_one_text_two_styles, :how_plink_works_three_text_one, :how_plink_works_three_text_one_styles,
      :how_plink_works_three_text_three, :how_plink_works_three_text_three_styles, :how_plink_works_three_text_two,
      :how_plink_works_three_text_two_styles, :how_plink_works_two_text_one, :how_plink_works_two_text_one_styles,
      :how_plink_works_two_text_three, :how_plink_works_two_text_three_styles, :how_plink_works_two_text_two,
      :how_plink_works_two_text_two_styles, :name, :partial_path, :sub_header_text_one, :sub_header_text_one_styles,
      :sub_header_text_two, :sub_header_text_two_styles

    validates_presence_of :name
    validates_presence_of :partial_path, if: lambda { cms == false }
    validates_presence_of :background_image_url, :button_text_one, :header_text_one,
      :how_plink_works_one_text_one, :how_plink_works_three_text_one,
      :how_plink_works_two_text_one, :sub_header_text_one,
      if: lambda { cms == true }
    validates :background_image_url, format: {with: /^https:\/\//},
      if: lambda { cms == true }
  end
end

