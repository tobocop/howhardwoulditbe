module Plink
  class DuplicateRegistrationAttemptRecord < ActiveRecord::Base
    self.table_name = 'duplicate_registration_attempts'

    attr_accessible :existing_users_institution_id, :user_id

    validates_presence_of :existing_users_institution_id, :user_id
  end
end
