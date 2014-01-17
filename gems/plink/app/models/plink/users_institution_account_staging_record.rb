module Plink
  class UsersInstitutionAccountStagingRecord < ActiveRecord::Base
    self.table_name = 'usersInstitutionAccountsStaging'

    include Plink::LegacyTimestamps

    attr_accessible :account_id, :account_number_hash, :account_number_last_four,
      :account_type, :account_type_description, :aggr_attempt_date, :aggr_status_code,
      :aggr_success_date, :currency_code, :in_intuit, :name, :status, :user_id,
      :users_institution_id

    attr_accessor :account_number

    alias_attribute :account_id, :accountID
    alias_attribute :account_number_hash, :accountNumberHash
    alias_attribute :account_number_last_four, :accountNumberLast4
    alias_attribute :account_type, :accountType
    alias_attribute :account_type_description, :accountTypeDescription
    alias_attribute :aggr_attempt_date, :aggrAttemptDate
    alias_attribute :aggr_status_code, :aggrStatusCode
    alias_attribute :aggr_success_date, :aggrSuccessDate
    alias_attribute :currency_code, :currencyCode
    alias_attribute :in_intuit, :inIntuit
    alias_attribute :name, :accountNickname
    alias_attribute :user_id, :userID
    alias_attribute :users_institution_id, :usersInstitutionID

    validates_presence_of :account_id, :user_id, :users_institution_id

    def values_for_final_account
      {
        account_id: account_id,
        account_number_hash: account_number_hash,
        account_number_last_four: account_number_last_four,
        account_type: account_type,
        account_type_description: account_type_description,
        aggr_attempt_date: aggr_attempt_date,
        aggr_status_code: aggr_status_code,
        aggr_success_date: aggr_success_date,
        begin_date: Date.current,
        currency_code: currency_code,
        end_date: 100.years.from_now.to_date,
        in_intuit: in_intuit,
        name: name,
        user_id: user_id,
        users_institution_account_staging_id: id,
        users_institution_id: users_institution_id
      }
    end
  end
end
