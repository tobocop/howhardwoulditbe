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

    attr_accessible :completed_on, :intuit_error_id, :is_active, :is_notification_successful,
      :started_on, :user_id, :users_institution_id, :users_intuit_error_id, :user_saw_question

    belongs_to :user_record, class_name: 'Plink::UserRecord', foreign_key: 'userID',
      conditions: ['users.isForceDeactivated = ?', false]
    belongs_to :users_institution_record, class_name: 'Plink::UsersInstitutionRecord', foreign_key: :usersInstitutionID

    has_one :institution_record, through: :users_institution_record

    scope :requiring_notice, -> {
      incomplete.
      where(%q{usersReverifications.isNotificationSuccessful = ? OR (
        usersReverifications.created > ? AND usersReverifications.created < ?
      )}, false, 3.days.ago.to_date, 2.days.ago.to_date)
    }

    scope :incomplete, -> {
      where('usersReverifications.isActive = ?', true).
      where('usersReverifications.completedOn IS NULL')
    }

    def link
      [108, 109].include?(intuit_error_id) ? institution_record.home_url : nil
    end

    def notice_type
      is_notification_successful ? 'three_day_reminder' : 'initial'
    end
  end
end
