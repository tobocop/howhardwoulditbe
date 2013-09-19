module Plink
  class ContestEntryService

    LINKED_CARD_MULTIPLIER = 5
    UNLINKED_CARD_MULTIPLIER = 1

    LINKED_REFERRAL_ENTRIES = 10

    def self.enter(contest_id, user_id, providers, options={})
      multiplier = user_multiplier(user_id)
      referral_entries = referral_entries(user_id, contest_id, multiplier)
      user = Plink::UserRecord.find(user_id)

      providers.map { |provider|
        entry_params = {
          contest_id: contest_id,
          user_id: user_id,
          provider: provider,
          multiplier: multiplier,
          referral_entries: referral_entries,
          computed_entries: multiplier + referral_entries,
          source: options[:entry_source]
        }

        Plink::EntryRecord.create(entry_params)
      }
    end

    def self.exceeded_daily_submission_limit?(user)
      Plink::EntryRecord.where(user_id: user.id)
      .where('created_at >= ?', Time.zone.today)
      .where('created_at < ?', Time.zone.today + 1.day).count >= 2
    end

    def self.total_entries(contest_id, user_id)
      Plink::EntryRecord.summed_computed_entries_by_contest_id_and_user_id(contest_id, user_id)
    end

    def self.total_entries_via_share(user_id, contest_id, linked_card, number_of_networks)
      multiplier = user_multiplier(user_id, linked_card)
      number_of_networks * (multiplier + referral_entries(user_id, contest_id, multiplier))
    end

    def self.user_multiplier(user_id, linked_card=false)
      return LINKED_CARD_MULTIPLIER if linked_card

      Plink::IntuitAccountService.new.user_has_account?(user_id) ?
        LINKED_CARD_MULTIPLIER : UNLINKED_CARD_MULTIPLIER
    end

  private

    def self.referral_entries(user_id, contest_id, multiplier)
      service = Plink::IntuitAccountService.new
      contest = Plink::ContestRecord.find(contest_id)
      referrals = Plink::ReferralConversionRecord.where(referredBy: user_id)
        .where('created >= ?', contest.start_time)
        .where('created < ?', contest.end_time)

      referral_values = referrals.map do |referral|
        service.user_has_account?(referral.created_user_id) ?
          LINKED_REFERRAL_ENTRIES * multiplier : 0
      end

      referral_values.inject(0) { |sum, value| sum + value }
    end
  end
end
