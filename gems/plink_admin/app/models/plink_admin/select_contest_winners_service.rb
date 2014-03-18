module PlinkAdmin
  class SelectContestWinnersService
    def self.process!(contest_id)
      cumulative_entries_by_user =
        PlinkAdmin::ContestWinningService.cumulative_non_plink_entries_by_user(contest_id)
      raise Exception.new("ERROR: Less than 300 entrants present! Cannot pick winners.") if cumulative_entries_by_user.length < 300

      PlinkAdmin::ContestWinningService.refresh_blacklisted_user_ids!

      outcome_table = PlinkAdmin::ContestWinningService.generate_outcome_table(cumulative_entries_by_user)

      total_entries =
        PlinkAdmin::ContestWinningService.total_non_plink_entries_for_contest(contest_id)

      winners = PlinkAdmin::ContestWinningService.choose_winners(total_entries, outcome_table)

      receiving_prize = winners.first(150)
      PlinkAdmin::ContestWinningService.create_prize_winners!(contest_id, receiving_prize)

      alternates = winners.last(150)
      PlinkAdmin::ContestWinningService.create_alternates!(contest_id, alternates)
    end
  end
end
