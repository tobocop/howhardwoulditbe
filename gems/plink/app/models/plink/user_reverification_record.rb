module Plink
  class UserReverificationRecord < ActiveRecord::Base
    self.table_name = 'usersReverifications'

    include Plink::LegacyTimestamps

    alias_attribute :user_id, :userID
    alias_attribute :users_institution_id, :usersInstitutionID
    alias_attribute :users_intuit_error_id, :usersIntuitErrorID
    alias_attribute :completed_on, :completedOn
    alias_attribute :is_active, :isActive

    attr_accessible :user_id, :users_institution_id, :users_intuit_error_id, :completed_on, :is_active

    def self.incomplete
      where("isActive = ?", true).where("completedOn IS NULL")
    end

  end
end