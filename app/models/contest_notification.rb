class ContestNotification
  def self.for_user(user_id, contest_id=nil)
    if Plink::EntryRecord.entries_today_for_user(user_id).exists?
      return {}
    elsif contest_id.present?
      points_and_dollars = Plink::ContestResultsService.points_and_dollars_for_user_and_contest(user_id, contest_id)
      partial = 'contest_winner'
    elsif contest = Plink::ContestRecord.current
      partial = 'enter_today'
    elsif contest = Plink::ContestRecord.last_finalized
      partial = 'contest_winner'
    else
      return {}
    end

    points_and_dollars ||= Plink::ContestResultsService.points_and_dollars_for_user_and_contest(user_id, contest.id)

    {
      contest: contest,
      dollars: points_and_dollars[:dollars],
      partial: partial,
      points: points_and_dollars[:points],
      user_id: user_id
    }
  end
end
