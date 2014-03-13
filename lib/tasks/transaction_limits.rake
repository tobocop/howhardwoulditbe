namespace :transaction_limits do
  desc 'runs the stored procedure alter to add office depot to the list of 10 transaction limit'
  task add_office_depot: :environment do
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'add_office_depot_to_enforce_transaction_limits.sql')))
  end
end
