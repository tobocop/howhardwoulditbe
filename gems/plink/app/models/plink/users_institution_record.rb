module Plink
  class UsersInstitutionRecord < ActiveRecord::Base
    self.table_name = 'usersInstitutions'

    include Plink::LegacyTimestamps

    belongs_to :institution_record, class_name: 'Plink::InstitutionRecord', foreign_key: 'institutionID'

    has_many :users_institution_account_records, class_name: 'UsersInstitutionAccountRecord', foreign_key: 'usersInstitutionID'
    has_many :users_institution_account_staging_records, class_name: 'UsersInstitutionAccountStagingRecord', foreign_key: 'usersInstitutionID'

    alias_attribute :hash_check, :hashCheck
    alias_attribute :institution_id, :institutionID
    alias_attribute :intuit_institution_login_id, :intuitInstitutionLoginID
    alias_attribute :is_active, :isActive
    alias_attribute :user_id, :userID

    attr_accessible :hash_check, :institution_id, :intuit_institution_login_id, :is_active,
      :user_id

    validates_presence_of :hash_check, :institution_id, :intuit_institution_login_id,
      :is_active, :user_id

    scope :hash_check_duplicates, ->(institution_id, hash_check, exclude_user_id) {
      where('institutionID = ?', institution_id).
      where('hashCheck = ?', hash_check).
      where('userID <> ?', exclude_user_id).
      where('isActive = ?', true)
    }

    def all_accounts_in_intuit
      users_institution_account_records.where(inIntuit: true) +
      users_institution_account_staging_records.where(inIntuit: true)
    end
  end
end
