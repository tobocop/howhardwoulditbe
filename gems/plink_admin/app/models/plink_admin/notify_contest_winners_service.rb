module PlinkAdmin
  class NotifyContestWinnersService
    def self.notify!(contest_id, automated_post)
      gigya = Gigya.new(Gigya::Config.instance)

      winners = Plink::ContestWinnerRecord.to_notify_by_contest_id(contest_id)
      winners.each do |winner|
        url = contest_referral_url(winner.user_id, contest_id) + '/facebook_winning_entry_post'
        facebook_status = "#{automated_post} #Plink #{url}"

        gigya.set_facebook_status(winner.user_id, facebook_status)
      end
    end

  private

    def self.default_affiliate_id
      1264
    end

    def self.contest_referral_url(user_id, contest_id)
      Rails.application.routes.url_helpers.contest_referral_url(
        user_id: user_id,
        affiliate_id: default_affiliate_id,
        contest_id: contest_id
      )
    end
  end
end
