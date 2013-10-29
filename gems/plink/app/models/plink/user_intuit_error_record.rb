module Plink
  class UserIntuitErrorRecord < ActiveRecord::Base
    self.table_name = 'usersIntuitErrors'

    alias_attribute :intuit_error_id, :intuitErrorID
    alias_attribute :users_institution_id, :usersInstitutionID
    alias_attribute :user_id, :userID

    attr_accessible :intuit_error_id, :users_institution_id, :user_id
  end
end

