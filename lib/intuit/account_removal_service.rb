module Intuit
  class AccountRemovalService
    def self.remove(intuit_account_id, user_id, users_institution_id)
      delete_response = Intuit::Request.new(user_id).delete_account(intuit_account_id)

      if delete_response[:status_code] == '200' || delete_response[:status_code] == '404'
        Plink::UsersInstitutionAccountRecord.where('accountID = ?', intuit_account_id)
          .update_all(isActive: false, inIntuit: false, endDate: Date.current)

        Plink::UsersInstitutionAccountStagingRecord.where('accountID = ?', intuit_account_id)
          .update_all(inIntuit: false)

        users_institution = Plink::UsersInstitutionRecord.find(users_institution_id)

        if users_institution.users_institution_account_records.where(inIntuit: true).blank?
          users_institution.update_attributes(is_active: false)

          Plink::UserReverificationRecord.where('usersInstitutionID = ?', users_institution.id)
            .update_all(isActive: false)

          Plink::UserIntuitErrorRecord.where('usersInstitutionID = ?', users_institution.id)
            .destroy_all

          Plink::IntuitFishyTransactionRecord.where('users_institution_id = ?', users_institution.id)
            .update_all(is_active: false)
        end
      end
    end
  end
end
