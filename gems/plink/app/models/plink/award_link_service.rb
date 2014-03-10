module Plink
  class AwardLinkService
    attr_reader :award_link_record, :user_id

    def initialize(url_value, user_id)
      @award_link_record = Plink::AwardLinkRecord.where(url_value: url_value).first
      @user_id = user_id
    end

    delegate :redirect_url, to: :award_link_record

    def track_click
      Plink::AwardLinkClickRecord.create(award_link_id: award_link_record.id, user_id: user_id)
    end

    def live?
      @award_link_record.start_date <= Date.current &&
        @award_link_record.end_date >= Date.current
    end

    def award
      Plink::FreeAwardService.new(award_link_record.dollar_award_amount).award_unique(user_id, award_link_record.award_type_id)
    end
  end
end
