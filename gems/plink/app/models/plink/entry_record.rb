module Plink
  class EntryRecord < ActiveRecord::Base
    self.table_name = 'entries'

    DAILY_LIMIT = 1

    PROVIDERS = {
      facebook: 'facebook',
      twitter: 'twitter',
      admin: 'admin'
    }

    belongs_to :contest_record, class_name: 'Plink::ContestRecord', foreign_key: 'contest_id'
    belongs_to :user_record, class_name: 'Plink::UserRecord', foreign_key: 'user_id'

    attr_accessible :computed_entries, :contest_id, :multiplier, :provider,
      :referral_entries, :user_id, :source
    attr_reader :facebook_entries_exceeded, :twitter_entries_exceeded, :contest_has_ended,
      :contest_has_not_started

    validates_presence_of :computed_entries, :contest_id, :multiplier, :referral_entries,
      :user_id, allow_nil: false

    validates :provider, inclusion: { in: PROVIDERS.values }

    validate :one_entry_per_provider_per_day, unless: ->(entry_record) {
      entry_record.provider == 'admin'
    }
    validate :contest_has_not_ended
    validate :contest_has_started

    scope :entries_today_for_user, ->(user_id) {
      where(user_id: user_id)
      .where('created_at >= ?', Time.zone.today)
      .where('created_at < ?', Time.zone.today + 1.day)
    }

    scope :entries_today_for_user_and_contest, ->(user_id, contest_id) {
      entries_today_for_user(user_id)
      .where(contest_id: contest_id)
    }

    def self.summed_computed_entries_by_contest_id_and_user_id(contest_id, user_id)
      where(contest_id: contest_id, user_id: user_id).sum('computed_entries')
    end

  private

    def one_entry_per_provider_per_day
      entries_today = Plink::EntryRecord.where(
        user_id: user_id,
        contest_id: contest_id,
        provider: provider)
      .where('created_at >= ?', Time.zone.today)
      .where('created_at < ?', Time.zone.today + 1.day)
      .count
      errors.add("#{provider}_entries_exceeded".to_sym) if entries_today >= DAILY_LIMIT
    end

    def contest_has_not_ended
      errors.add(:contest_has_ended) if contest_record && contest_record.ended?
    end

    def contest_has_started
      if contest_record
        errors.add(:contest_has_not_started) unless contest_record.started?
      end
    end

  end
end
