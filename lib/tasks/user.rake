namespace :user do

  desc 'One-time task to backfill registration `provider` field for users'
  task backfill_registration_provider: :environment do
    users_with_facebook = Plink::UserRecord.where('fbUserID IS NOT NULL')
    users_with_facebook.update_all(provider: 'facebook')

    users_without_facebook = Plink::UserRecord.where('fbUserID IS NULL')
    users_without_facebook.update_all(provider: 'organic')
  end

end
