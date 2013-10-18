module PlinkAdmin
  class ContestWinningQueryService
    def self.winning_users_grouped_by_prize_level(contest_id)
      select_joins_where(contest_id).
      where('contest_winners.prize_level_id IS NOT NULL').
      group(group).
      order('contest_winners.id ASC').
      group_by {|winner| winner.prize_level_id }
    end

    def self.alternates(contest_id)
      select_joins_where(contest_id).
      where('contest_winners.prize_level_id IS NULL').
      where('contest_winners.finalized_at IS NULL').
      group(group).
      order('contest_winners.id ASC')
    end

    def self.rejected(contest_id)
      select_joins_where(contest_id).
      where('contest_winners.rejected = ?', true).
      group(group).
      order('contest_winners.id ASC')
    end

  private

    def self.select
      <<-END
        users.userID user_id,
        SUM(entries.computed_entries) entries,
        institutionName AS institution,
        users.emailAddress,
        contest_winners.prize_level_id prize_level_id,
        (CASE WHEN fishy.id IS NOT NULL THEN 1 ELSE 0 END) fishy,
        contest_winners.id contest_winners_id
      END
    end

    def self.select_joins_where(contest_id)
      Plink::UserRecord.
        select(select).
        joins('INNER JOIN contest_winners ON users.userID = contest_winners.user_id').
        joins('INNER JOIN entries ON users.userID = entries.user_id AND entries.user_id = contest_winners.user_id').
        joins('LEFT JOIN contest_prize_levels ON contest_prize_levels.id = contest_winners.prize_level_id').
        joins('LEFT JOIN (SELECT user_id, MAX(uia_id) uia_id FROM vw_active_intuit_accounts GROUP BY user_id) max_uia_id_by_user ON users.userID = max_uia_id_by_user.user_id').
        joins('LEFT JOIN usersInstitutionAccounts ON max_uia_id_by_user.uia_id = usersInstitutionAccounts.usersInstitutionAccountID').
        joins('LEFT JOIN usersInstitutions ON usersInstitutionAccounts.usersInstitutionID = usersInstitutions.usersInstitutionID').
        joins('LEFT JOIN institutions ON usersInstitutions.institutionID = institutions.institutionID').
        joins('LEFT JOIN (SELECT user_id, MAX(id) AS id FROM intuit_fishy_transactions WHERE is_active = 1 GROUP BY user_id) fishy ON users.userID = fishy.user_id').
        where('contest_winners.contest_id = ? AND entries.contest_id = ?', contest_id, contest_id)
    end

    def self.group
      <<-END
        users.userID,
        users.emailAddress,
        institutionName,
        dollar_amount,
        contest_winners.id,
        contest_winners.prize_level_id,
        fishy.id,
        contest_winners.id
      END
    end
  end
end
