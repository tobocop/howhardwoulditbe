namespace :intuit do
  desc 'Removes accounts from intuit that are in intuit_accounts_to_remove'
  task remove_accounts: :environment do
    accounts = Plink::IntuitAccountToRemoveRecord.all

    accounts.each do |account|
      Intuit::AccountRemovalService.delay(queue: 'intuit_account_removals').remove(account.intuit_account_id, account.user_id, account.users_institution_id)
      Plink::IntuitAccountToRemoveRecord.destroy(account.id)
    end
  end
end

