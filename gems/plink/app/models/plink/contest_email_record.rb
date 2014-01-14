module Plink
  class ContestEmailRecord < ActiveRecord::Base
    self.table_name = 'contest_emails'

    belongs_to :contest_record, class_name: 'Plink::ContestRecord', foreign_key: 'contest_id'

    attr_accessible :contest_id, :day_one_body, :day_one_image, :day_one_link_text,
      :day_one_preview, :day_one_subject

    validates_presence_of :day_one_body, :day_one_image, :day_one_link_text, :day_one_preview,
      :day_one_subject
  end
end
