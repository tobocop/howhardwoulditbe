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

  desc 'Removes accounts from intuit that are staged and have not been chosen'
  task remove_inactive_accounts: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning intuit:remove_inactive_accounts"

      inactive_intuit_accounts.each do |inactive_account|
        begin
          Intuit::AccountRemovalService.delay(queue: 'intuit_account_removals').remove(
            inactive_account.account_id,
            inactive_account.user_id,
            inactive_account.users_institution_id
          )
          puts "[#{Time.zone.now}] Removing account with users_institution_account_staging.id = #{inactive_account.id}"
        rescue Exception => e
          ::Exceptional::Catcher.handle($!, "intuit:remove_inactive_accounts Rake task failed on users_institution_account_staging.id = #{inactive_account.id}")
        end
      end
n
      puts "[#{Time.zone.now}] Ending intuit:remove_inactive_accounts"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "intuit:remove_inactive_accounts Rake task failed")
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

  desc 'Adds the chase institution to the institutions table'
  task add_chase: :environment do
    institution_request = Intuit::Request.new(0)
    data = institution_request.institution_data(13278)[:result][:institution_detail]
    puts "DERP"
    puts data[:institution_name]
    puts "DERP"
    Plink::InstitutionRecord.create(
      hash_value: "val",
      home_url: data[:home_url],
      intuit_institution_id: data[:institution_id],
      is_active: true,
      is_supported: true,
      name: data[:institution_name]
    )
    puts "chase added"
  end

  desc 'Adds the chase institution to the institutions table'
  task download_one: :environment do
    request = Intuit::Request.new(5)
    transactions = request.get_transactions(400169646974, 7.days.ago)

    puts transactions
  end

  desc 'puts to stdout institution info'
  task output_institution_json: :environment do
    institutions_request = Intuit::Request.new(0)
    institutions = institutions_request.institutions
    puts institutions
  end

private

  def inactive_intuit_accounts
    Plink::UsersInstitutionAccountStagingRecord.inactive_intuit_accounts
  end

  def stars
    puts '*' * 150
  end
end
