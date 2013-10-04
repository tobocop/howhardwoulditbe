module Plink
  class ContestBlacklistedEmailRecord < ActiveRecord::Base
    self.table_name = 'contest_blacklisted_emails'

    attr_accessible :email_pattern

    validates_presence_of :email_pattern
  end
end
