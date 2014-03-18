module Plink
  class ContestRecord < ActiveRecord::Base
    self.table_name = 'contests'

    has_many :entry_records, class_name: 'Plink::EntryRecord', foreign_key: 'contest_id'
    has_many :contest_prize_levels, class_name: 'Plink::ContestPrizeLevelRecord', foreign_key: 'contest_id'
    has_many :contest_winners, class_name: 'Plink::ContestWinnerRecord', foreign_key: 'contest_id'
    has_one :contest_emails, class_name: 'Plink::ContestEmailRecord', foreign_key: 'contest_id'

    accepts_nested_attributes_for :contest_emails
    accepts_nested_attributes_for :contest_prize_levels, allow_destroy: true, reject_if: :all_blank

    attr_accessible :contest_emails_attributes, :contest_prize_levels_attributes, :description, :disclaimer_text, :end_time, :entry_method,
      :entry_notification, :entry_post_body, :entry_post_title, :finalized_at, :image,
      :interstitial_body_text, :interstitial_bold_text, :interstitial_share_button,
      :interstitial_reg_link, :interstitial_title, :non_linked_image, :prize, :prize_description,
      :start_time, :terms_and_conditions, :winning_post_body, :winning_post_title

    attr_reader :start_time_overlaps_existing_range, :end_time_overlaps_existing_range,
      :end_time_less_than_start_time

    validates_presence_of :description, :end_time, :entry_notification, :entry_post_body,
      :entry_post_title, :image, :prize, :prize_description, :start_time, :terms_and_conditions,
      :winning_post_body, :winning_post_title

    validate :start_time_is_not_between_existing_range
    validate :end_time_is_not_between_existing_range
    validate :end_time_after_start_time

    scope :other_contests_within_time, ->(id, time) {
      id = id ? id : 0

      where('end_time > ?', time)
      .where('start_time < ?', time)
      .where('id != ?', id)
    }

    def self.current
      now = Time.zone.now
      contest = self.where('start_time <= ? AND ? < end_time', now, now)

      contest.present? ? contest.first : nil
    end

    def ended?
      Time.zone.now > end_time
    end

    def started?
      Time.zone.now > start_time
    end

    def finalized?
      finalized_at.present?
    end

    def self.last_completed
      where('finalized_at IS NULL AND end_time < ?', Time.zone.now).first
    end

    def self.last_finalized
      where('finalized_at IS NOT NULL').order('end_time DESC').first
    end

    private

    def start_time_is_not_between_existing_range
      if start_time
        overlap = find_overlaps(start_time)
        errors.add(:start_time_overlaps_existing_range) if overlap.length > 0
      end
    end

    def end_time_is_not_between_existing_range
      if end_time
        overlap = find_overlaps(end_time)
        errors.add(:end_time_overlaps_existing_range) if overlap.length > 0
      end
    end

    def find_overlaps(time)
      self.class.other_contests_within_time(id, time)
    end

    def end_time_after_start_time
      if end_time && start_time
        errors.add(:end_time_less_than_start_time) if end_time < start_time
      end
    end
  end
end
