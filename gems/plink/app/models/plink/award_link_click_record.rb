module Plink
  class AwardLinkClickRecord < ActiveRecord::Base
    self.table_name = 'award_link_clicks'

    attr_accessible :award_link_id, :user_id
  end
end
