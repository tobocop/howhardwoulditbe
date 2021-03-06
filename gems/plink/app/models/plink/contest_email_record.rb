module Plink
  class ContestEmailRecord < ActiveRecord::Base
    self.table_name = 'contest_emails'

    belongs_to :contest_record, class_name: 'Plink::ContestRecord', foreign_key: 'contest_id'

    attr_accessible :contest_id, :day_one_body, :day_one_image, :day_one_link_text,
      :day_one_preview, :day_one_subject, :three_day_body, :three_day_image, :three_day_link_text,
      :three_day_preview, :three_day_subject, :winner_body, :winner_image, :winner_link_text,
      :winner_preview, :winner_subject

    validates_presence_of :day_one_body, :day_one_image, :day_one_link_text, :day_one_preview,
      :day_one_subject, :three_day_body, :three_day_image, :three_day_link_text,
      :three_day_preview, :three_day_subject, :winner_body, :winner_image, :winner_link_text,
      :winner_preview, :winner_subject

    def self.find_by_contest_id(id)
      where(contest_id: id).first
    end
  end
end
