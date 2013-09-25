module Plink
  class ContestPrizeLevelRecord < ActiveRecord::Base
    self.table_name = 'contest_prize_levels'

    attr_accessible :award_count, :contest_id, :dollar_amount

    validates_presence_of :award_count, :contest_id, :dollar_amount
  end
end
