module Plink
  class ContestWinnerRecord < ActiveRecord::Base
    self.table_name = 'contest_winners'

    has_one :contest, class_name: Plink::ContestRecord
    has_one :user, class_name: Plink::UserRecord, foreign_key: 'userID'
    attr_accessible :admin_user_id, :contest_id, :finalized_at,
      :prize_level_id, :rejected, :user_id, :winner

    validates_presence_of :contest_id, :user_id
    validates :rejected, :winner, inclusion: { in: [true, false] }

    scope :for_contest, ->(contest_id) {
      select('contest_winners.*, contests.finalized_at AS contest_finalized_at, contest_prize_levels.dollar_amount, users.firstName AS first_name, users.lastName AS last_name').
      joins('INNER JOIN users ON contest_winners.user_id = users.userID').
      joins('INNER JOIN contests ON contest_winners.contest_id = contests.id').
      joins('LEFT OUTER JOIN contest_prize_levels ON contest_winners.prize_level_id = contest_prize_levels.id').
      where('contests.id = ?', contest_id)
    }
  end
end
