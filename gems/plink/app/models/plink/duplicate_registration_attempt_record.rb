module Plink
  class DuplicateRegistrationAttemptRecord < ActiveRecord::Base
    self.table_name = 'duplicate_registration_attempts'

    attr_accessible :existing_users_institution_id, :user_id

    validates_presence_of :existing_users_institution_id, :user_id

    scope :duplicates_by_user_id, -> (user_id) {
      select(%q{
        duplicate_registration_attempts.created_at,
        institutions.institutionName AS institution_name,
        users.userID AS duplicate_user_id,
        users.firstName AS duplicate_user_first_name,
        users.emailAddress AS duplicate_user_email
      }).
      joins('INNER JOIN usersInstitutions ON duplicate_registration_attempts.existing_users_institution_id = usersInstitutions.usersInstitutionID').
      joins('INNER JOIN institutions ON usersInstitutions.institutionID = institutions.institutionID').
      joins('INNER JOIN users ON users.userID = usersInstitutions.userID').
      where(user_id: user_id)
    }
  end
end
