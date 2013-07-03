module Plink
  class UsersAwardPeriodRecord < ActiveRecord::Base
    self.table_name = 'usersAwardPeriods'

    include LegacyTimestamps

    alias_attribute :user_id, :userID
    alias_attribute :begin_date, :beginDate
    alias_attribute :advertisers_rev_share, :advertisersRevShare
    alias_attribute :end_date, :endDate

    attr_accessible :user_id, :wallet_item_id, :begin_date, :advertisers_rev_share

    def initialize(attributes = nil, options = {})
      super
      self.end_date ||= 100.years.from_now.at_midnight
    end
  end
end