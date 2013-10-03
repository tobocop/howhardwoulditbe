module Plink
  class ContestWinnerRecord < ActiveRecord::Base
    self.table_name = 'contest_winners'

    belongs_to :contest, class_name: Plink::ContestRecord, foreign_key: 'contest_id'
    belongs_to :prize_level, class_name: Plink::ContestPrizeLevelRecord, foreign_key: 'prize_level_id'
    belongs_to :user, class_name: Plink::UserRecord, foreign_key: 'user_id'

    attr_accessible :admin_user_id, :contest_id, :finalized_at,
      :prize_level_id, :rejected, :user_id, :winner

    validates_presence_of :contest_id, :user_id
    validates :rejected, :winner, inclusion: { in: [true, false] }

    # TODO: This should probably be moved to a service. See https://github.com/plinkinc/plink-pivotal/commit/848d2f21312d817d3adb7aef1d132a1b270501d3
    scope :for_contest, ->(contest_id) {
      select('contest_winners.*, contests.finalized_at AS contest_finalized_at, contest_prize_levels.dollar_amount, users.firstName AS first_name, users.lastName AS last_name').
      joins('INNER JOIN users ON contest_winners.user_id = users.userID').
      joins('INNER JOIN contests ON contest_winners.contest_id = contests.id').
      joins('LEFT OUTER JOIN contest_prize_levels ON contest_winners.prize_level_id = contest_prize_levels.id').
      where('contests.id = ?', contest_id)
    }
  end
end
