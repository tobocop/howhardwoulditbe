module Plink
  class ContestBlacklistedEmailRecord < ActiveRecord::Base
    self.table_name = 'contest_blacklisted_user_ids'

    attr_accessible :user_id

    validates_presence_of :user_id
  end
end
