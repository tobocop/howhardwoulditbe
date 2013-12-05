module Plink
  class UsersInstitutionAccountRecord < ActiveRecord::Base

    self.table_name = 'usersInstitutionAccounts'

    include Plink::LegacyTimestamps

    alias_attribute :account_id, :accountID
    alias_attribute :account_number_hash, :accountNumberHash
    alias_attribute :account_number_last_four, :accountNumberLast4
    alias_attribute :account_type, :accountType
    alias_attribute :account_type_description, :accountTypeDescription
    alias_attribute :aggr_attempt_date, :aggrAttemptDate
    alias_attribute :aggr_status_code, :aggrStatusCode
    alias_attribute :aggr_success_date, :aggrSuccessDate
    alias_attribute :begin_date, :beginDate
    alias_attribute :currency_code, :currencyCode
    alias_attribute :end_date, :endDate
    alias_attribute :in_intuit, :inIntuit
    alias_attribute :is_active, :isActive
    alias_attribute :name, :accountNickname
    alias_attribute :user_id, :userID
    alias_attribute :users_institution_account_staging_id, :usersInstitutionAccountStagingID
    alias_attribute :users_institution_id, :usersInstitutionID

    attr_accessible :account_id, :account_number_hash, :account_number_last_four,
      :account_type, :account_type_description, :aggr_attempt_date, :aggr_status_code,
      :aggr_success_date, :begin_date, :currency_code, :end_date, :in_intuit, :is_active,
      :name, :user_id, :users_institution_account_staging_id, :users_institution_id
  end
end
