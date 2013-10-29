module Plink
  class UsersInstitutionRecord < ActiveRecord::Base
    self.table_name = 'usersInstitutions'

    include Plink::LegacyTimestamps

    belongs_to :institution_record, class_name: 'Plink::InstitutionRecord', foreign_key: 'institutionID'

    has_many :users_institution_account_records, class_name: 'UsersInstitutionAccountRecord', foreign_key: 'usersInstitutionID'

    alias_attribute :institution_id, :institutionID
    alias_attribute :intuit_institution_login_id, :intuitInstitutionLoginID
    alias_attribute :is_active, :isActive
    alias_attribute :user_id, :userID
    alias_attribute :hash_check, :hashCheck

    attr_accessible :institution_id, :intuit_institution_login_id, :is_active, :user_id,
      :hash_check
  end
end
