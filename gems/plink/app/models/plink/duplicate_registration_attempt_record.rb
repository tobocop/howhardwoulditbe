module Plink
  class DuplicateRegistrationAttemptRecord < ActiveRecord::Base
    self.table_name = 'duplicate_registration_attempts'

    attr_accessible :user_id, :existing_user_id

    validates_presence_of :user_id, :existing_user_id
  end
end
