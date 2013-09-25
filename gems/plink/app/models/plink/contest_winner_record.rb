module Plink
  class ContestWinnerRecord < ActiveRecord::Base
    self.table_name = 'contest_winners'

    attr_accessible :contest_id, :finalized, :prize_level_id, :rejected, :user_id, :winner

    validates_presence_of :contest_id, :user_id
    validates :rejected, :winner, inclusion: { in: [true, false] }
  end
end
