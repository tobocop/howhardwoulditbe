namespace :intuit do
  desc 'Removes accounts from intuit that are in intuit_accounts_to_remove'
  task remove_accounts: :environment do
    accounts = Plink::IntuitAccountToRemoveRecord.all

    accounts.each do |account|
      delete_response = Aggcat.scope(account.user_id).delete_account(account.intuit_account_id)

      if delete_response[:status_code] == '200' || delete_response[:status_code] == '404'
        Plink::UsersInstitutionAccountRecord.where('accountID = ?', account.intuit_account_id)
          .update_all(isActive: false, inIntuit: false, endDate: Date.current)

        Plink::UsersInstitutionAccountStagingRecord.where('accountID = ?', account.intuit_account_id)
          .update_all(inIntuit: false)

        users_institution = Plink::UsersInstitutionRecord.find(account.users_institution_id)

        if users_institution.users_institution_account_records.where(inIntuit: true).blank?
          users_institution.update_attributes(is_active: false)

          Plink::UserReverificationRecord.where('usersInstitutionID = ?', users_institution.id)
            .update_all(isActive: false)

          Plink::UserIntuitErrorRecord.where('usersInstitutionID = ?', users_institution.id)
            .destroy_all

          Plink::IntuitFishyTransactionRecord.where('users_institution_id = ?', users_institution.id)
            .update_all(is_active: false)
        end

        Plink::IntuitAccountToRemoveRecord.destroy(account.id)
      end
    end
  end
end

