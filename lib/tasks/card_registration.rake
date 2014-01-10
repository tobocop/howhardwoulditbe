namespace :card_registration do
  desc 'Task to remove Plink::IntuitAccountRequestRecords that are more than 30 minutes old'
  task remove_old_intuit_account_request_records: :environment do
    Plink::IntuitRequestRecord.where('created_at <= ?', 30.minutes.ago).delete_all
  end
end
