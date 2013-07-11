module Plink
  class UsersInstitutionAccountRecord < ActiveRecord::Base

    self.table_name = 'usersInstitutionAccounts'

    include Plink::LegacyTimestamps

    alias_attribute :account_id, :accountID
    alias_attribute :begin_date, :beginDate
    alias_attribute :end_date, :endDate
    alias_attribute :user_id, :userID
    alias_attribute :users_institution_account_staging_id, :usersInstitutionAccountStagingID
    alias_attribute :users_institution_id, :usersInstitutionID
    alias_attribute :is_active, :isActive
    alias_attribute :in_intuit, :inIntuit
    alias_attribute :name, :accountNickname
    alias_attribute :account_number_last_four, :accountNumberLast4

    attr_accessible :account_id,
                    :begin_date,
                    :end_date,
                    :user_id,
                    :users_institution_account_staging_id,
                    :users_institution_id,
                    :is_active,
                    :in_intuit,
                    :name,
                    :account_number_last_four


  end
end