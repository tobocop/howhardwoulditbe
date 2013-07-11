module Plink
  class ActiveIntuitAccountRecord < ActiveRecord::Base

    self.table_name = 'vw_active_intuit_accounts'

    belongs_to :users_institution_account_record, class_name: 'Plink::UsersInstitutionAccountRecord', foreign_key: 'uia_id'
    belongs_to :users_institution_record, class_name: 'Plink::UsersInstitutionRecord', foreign_key: 'users_institution_id'

    has_one :institution_record, through: :users_institution_record

    def self.user_has_account?(user_id)
      where(user_id: user_id).first.present?
    end

    def bank_name
      institution_record.name
    end

    def account_name
      users_institution_account_record.name
    end

    def account_number_last_four
      users_institution_account_record.account_number_last_four
    end

  end
end