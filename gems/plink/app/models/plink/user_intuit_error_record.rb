module Plink
  class UserIntuitErrorRecord < ActiveRecord::Base
    self.table_name = 'usersIntuitErrors'

    IMMEDIATE_ATTENTION_ERROR_CODES = [103, 106, 108, 109]
    FIVE_DAY_ERROR_CODES = [185, 187]

    alias_attribute :intuit_error_id, :intuitErrorID
    alias_attribute :users_institution_id, :usersInstitutionID
    alias_attribute :user_id, :userID

    attr_accessible :intuit_error_id, :users_institution_id, :user_id

    scope :errors_that_require_immediate_attention, -> {
      where('intuitErrorID IN (?)', immediate_attention_error_codes).
      where('created > ?', Date.current)
    }

    scope :errors_occuring_five_consecutive_days, -> {
      select('max(usersIntuitErrorID) as usersIntuitErrorID, userID, usersInstitutionID, intuitErrorID').
      where('intuitErrorID in (?)', five_day_error_codes).
      where('created > ?', 5.days.ago.to_date).
      group('userID, usersInstitutionID, intuitErrorID').
      having('count(1) >= 5')
    }

    def self.errors_that_require_attention
      errors_that_require_immediate_attention + errors_occuring_five_consecutive_days
    end

    def self.immediate_attention_error_codes
      IMMEDIATE_ATTENTION_ERROR_CODES
    end

    def self.five_day_error_codes
      FIVE_DAY_ERROR_CODES
    end
  end
end

