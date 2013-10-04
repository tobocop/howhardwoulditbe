class ContestNotificationPresenter
  def self.for_user(user_id, contest_id=nil)
    if Plink::EntryRecord.entries_today_for_user(user_id).exists?
      nil
    elsif contest_id.present?
      points_and_dollars = Plink::ContestResultsService.points_and_dollars_for_user_and_contest(user_id, contest_id)

      { partial: 'contest_winner',
        data: {
          contest_id: contest_id,
          dollars: points_and_dollars[:dollars],
          points: points_and_dollars[:points],
          user_id: user_id
        }
      }
    elsif contest = Plink::ContestRecord.current
      { partial: 'enter_today' }
    elsif contest = Plink::ContestRecord.last_finalized
      points_and_dollars = Plink::ContestResultsService.points_and_dollars_for_user_and_contest(user_id, contest.id)

      { partial: 'contest_winner',
        data: {
          contest_id: contest.id,
          dollars: points_and_dollars[:dollars],
          points: points_and_dollars[:points],
          user_id: user_id
        }
      }
    else
      nil
    end
  end
end
