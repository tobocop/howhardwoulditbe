module Plink
  class UsersInstitutionAccountStagingRecord < ActiveRecord::Base
    self.table_name = 'usersInstitutionAccountsStaging'

    include Plink::LegacyTimestamps

    alias_attribute :account_id, :accountID
    alias_attribute :account_number_last_four, :accountNumberLast4
    alias_attribute :user_id, :userID
    alias_attribute :users_institution_id, :usersInstitutionID
    alias_attribute :in_intuit, :inIntuit
    alias_attribute :name, :accountNickname

    attr_accessible :account_id, :account_number_last_four, :user_id, :users_institution_id,
      :in_intuit, :name
  end
end
