namespace :intuit do
  desc 'Removes accounts from intuit that are in intuit_accounts_to_remove'
  task remove_accounts: :environment do
    accounts = Plink::IntuitAccountToRemoveRecord.all

    accounts.each do |account|
      Intuit::AccountRemovalService.delay(queue: 'intuit_account_removals').remove(account.intuit_account_id, account.user_id, account.users_institution_id)
      Plink::IntuitAccountToRemoveRecord.destroy(account.id)
    end
  end

  desc 'Removes accounts from intuit that are staged and have not been chosen'
  task remove_staged_accounts: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning intuit:remove_staged_accounts"

      staged_accounts_to_remove.each do |staged_account|
        begin
          Intuit::AccountRemovalService.delay(queue: 'intuit_account_removals').remove(
              staged_account.account_id,
              staged_account.user_id,
              staged_account.users_institution_id
            )
          puts "[#{Time.zone.now}] Removing account with users_institution_account_staging.id = #{staged_account.id}"
        rescue Exception => e
          ::Exceptional::Catcher.handle("intuit:remove_staged_accounts Rake task failed on users_institution_account_staging.id = #{staged_account.id} with #{$!}")
        end
      end

      puts "[#{Time.zone.now}] Ending intuit:remove_staged_accounts"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle("intuit:remove_staged_accounts Rake task failed #{$!}")
    end
  end

private

  def staged_accounts_to_remove
    Plink::UsersInstitutionAccountStagingRecord.
      joins('LEFT OUTER JOIN usersInstitutionAccounts ON
        usersInstitutionAccounts.usersInstitutionAccountStagingID = usersInstitutionAccountsStaging.usersInstitutionAccountStagingID').
      where('usersInstitutionAccounts.usersInstitutionAccountStagingID IS NULL').
      where('usersInstitutionAccountsStaging.created < ?', 2.days.ago).
      where('usersInstitutionAccountsStaging.inIntuit = ?', true)
  end

  def stars
    puts '*' * 150
  end
end

