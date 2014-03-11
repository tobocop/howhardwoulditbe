module Plink
  class AwardLinkRecord < ActiveRecord::Base
    self.table_name = 'award_links'

    attr_accessible :award_type_id, :dollar_award_amount, :end_date, :is_active, :name,
      :redirect_url, :start_date, :url_value

    validates_presence_of :name, :redirect_url

    before_create :generate_url_value

  private

    def generate_url_value
      begin
        self[:url_value] = SecureRandom.urlsafe_base64(45)
      end while self.class.where(url_value: url_value).present?
    end
  end
end
