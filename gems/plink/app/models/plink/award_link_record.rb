module Plink
  class AwardLinkRecord < ActiveRecord::Base
    self.table_name = 'award_links'

    attr_accessible :award_type_id, :dollar_award_amount, :end_date, :is_active, :redirect_url,
      :start_date, :url_value
  end
end
