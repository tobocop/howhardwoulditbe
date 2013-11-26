module Plink
  class UserReverificationRecord < ActiveRecord::Base
    self.table_name = 'usersReverifications'

    include Plink::LegacyTimestamps

    alias_attribute :completed_on, :completedOn
    alias_attribute :is_active, :isActive
    alias_attribute :is_notification_successful, :isNotificationSuccessful
    alias_attribute :started_on, :startedOn
    alias_attribute :user_id, :userID
    alias_attribute :users_institution_id, :usersInstitutionID
    alias_attribute :users_intuit_error_id, :usersIntuitErrorID
    alias_attribute :user_saw_question, :userSawQuestion

    attr_accessible :completed_on, :is_active, :is_notification_successful, :started_on,
      :user_id, :users_institution_id, :users_intuit_error_id, :user_saw_question

    def self.incomplete
      where("isActive = ?", true).where("completedOn IS NULL")
    end
  end
end
