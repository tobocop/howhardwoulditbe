namespace :vw_active_intuit_accounts do
  desc 'One-time task to remove oauth tokens from vw_active_intuit_accounts'
  task remove_oauth_tokens: :environment do
    ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'alter_vw_active_intuit_accounts.sql')))
  end
end
