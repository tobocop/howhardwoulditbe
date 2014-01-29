namespace :db do
  desc 'Creates an MS SQL database based on an argument'
  task :create_ms_sql, [:database_name] => :environment do |t, args|
    db_name = args[:database_name]
    raise ArgumentError.new('database_name is required') unless db_name.present?
    ActiveRecord::Base.connection.execute("CREATE DATABASE #{db_name}")
  end

  task :drop_ms_sql, [:database_name] => :environment do |t, args|
    db_name = args[:database_name]
    raise ArgumentError.new('database_name is required') unless db_name.present?
    ActiveRecord::Base.connection.execute("DROP DATABASE #{db_name}")
  end

  namespace :views do

    desc 'Creates the views in the DB'
    task :create => :environment do
      #Rolls up freeAwards qualifyingAwards and nonQualifyingAwards
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_awards.sql')))
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'alter_vw_awards.sql')))
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_allRewards.sql')))

      #Rolls up all purchases and redemptions of a user
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_debitsCredits.sql')))

      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_userBalances.sql')))

      #only returns active oauth tokens. They can expire periodically
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_oauth_tokens.sql')))

      #Returns everyone we currently consider to be active in intuit and in our system
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_active_intuit_accounts.sql')))
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'alter_vw_active_intuit_accounts.sql')))

      #Adds the 10% control group for retail
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_offer_exclusions.sql')))

      #Adds view for reverifications for the mobile api
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_user_has_reverifications.sql')))

      #View for rails reg to get the current active paths for a given affiliate
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_active_paths.sql')))

      #View for redemption limits
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_tango24hourRedemptions.sql')))

    end

    desc 'drops the views in the DB'
    task :drop => :environment do
      ActiveRecord::Base.connection.execute('DROP VIEW vw_awards')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_allRewards')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_debitsCredits')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_userBalances')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_oauth_tokens')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_active_intuit_accounts')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_offerExclusions')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_user_has_reverifications')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_activePaths')
      ActiveRecord::Base.connection.execute('DROP VIEW vw_tango24hourRedemptions')
    end
  end

  namespace :udfs do
    desc 'create the user defined functions in the db'
    task :create => :environment do
      #We need fuzzy dates for awarding. The vw_active_intuit_accounts view is also dependant on these udfs
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_udf_getFuzzyDateValue.sql')))
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_udf_calculateFuzzyDate.sql')))
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_udf_getDateOnly.sql')))
    end

    desc 'drop the user defined functions in the db'
    task :drop => :environment do
      ActiveRecord::Base.connection.execute('DROP FUNCTION udf_getFuzzyDateValue')
      ActiveRecord::Base.connection.execute('DROP FUNCTION udf_calculateFuzzyDate')
      ActiveRecord::Base.connection.execute('DROP FUNCTION udf_getDateOnly')
    end
  end

  namespace :stored_procs do
    desc 'create the stored procedures in the db'
    task :create => :environment do
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_prc_getUsersWalletByWalletID.sql')))
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_prc_enforce_transaction_limits.sql')))
    end

    desc 'drop the stored procedures in the db'
    task :drop => :environment do
      ActiveRecord::Base.connection.execute('DROP PROCEDURE prc_getUsersWalletByWalletID')
      ActiveRecord::Base.connection.execute('DROP PROCEDURE prc_enforce_transaction_limits')
    end
  end
end
