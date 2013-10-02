module Plink
  class ContestRecord < ActiveRecord::Base
    self.table_name = 'contests'

    has_many :entry_records, class_name: 'Plink::EntryRecord', foreign_key: 'contest_id'

    attr_accessible :description, :end_time, :entry_method, :finalized_at, :image, :prize,
      :start_time, :terms_and_conditions

    attr_reader :start_time_overlaps_existing_range, :end_time_overlaps_existing_range,
      :end_time_less_than_start_time

    validates_presence_of :description, :end_time, :image, :prize, :start_time,
      :terms_and_conditions

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
