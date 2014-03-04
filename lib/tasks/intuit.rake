namespace :intuit do
  desc 'Removes accounts from intuit that are in intuit_accounts_to_remove'
  task remove_accounts: :environment do
    accounts = Plink::IntuitAccountToRemoveRecord.all

    accounts.each do |account|
      StatsD.increment('rake.intuit.remove_account')
      Intuit::AccountRemovalService.delay(queue: 'intuit_account_removals').remove(account.intuit_account_id, account.user_id, account.users_institution_id)
      Plink::IntuitAccountToRemoveRecord.destroy(account.id)
    end
  end

  desc 'Removes accounts from intuit for users that have been force-deactivated'
  task remove_force_deactivated_accounts: :environment do
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
          ::Exceptional::Catcher.handle($!, "intuit:remove_staged_accounts Rake task failed on users_institution_account_staging.id = #{staged_account.id}")
        end
      end

      puts "[#{Time.zone.now}] Ending intuit:remove_staged_accounts"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "intuit:remove_staged_accounts Rake task failed")
    end
  end

  desc 'Update account type'
  task :update_account_type, [:users_institution_account_id, :account_type] => :environment do |t, args|
    users_institution_account_id = args[:users_institution_account_id]
    raise ArgumentError.new('users_institution_account_id is required') unless users_institution_account_id.present?

    account_type = IntuitAccountType.AccountType(args[:account_type])
    raise ArgumentError.new('account_type is invalid') unless account_type.present?

    account = Plink::UsersInstitutionAccountRecord.find(users_institution_account_id)

    begin
      Intuit::Request.new(account.user_id).update_account_type(account.account_id, account_type)
    rescue NoMethodError
      message = "Could not set scope (check intuit.yml) for user.id = #{account.user_id}, users_institution_account_id = #{users_institution_account_id}"
      raise $!, "#{message} #{$!}", $!.backtrace
    end
  end

private

  def staged_accounts_to_remove
    Plink::UsersInstitutionAccountStagingRecord.
      joins('LEFT OUTER JOIN usersInstitutionAccounts ON
        usersInstitutionAccounts.accountID = usersInstitutionAccountsStaging.accountID').
      where('usersInstitutionAccounts.usersInstitutionAccountStagingID IS NULL').
      where('usersInstitutionAccountsStaging.created < ?', 2.days.ago).
      where('usersInstitutionAccountsStaging.inIntuit = ?', true)
  end

  def stars
    puts '*' * 150
  end
end
