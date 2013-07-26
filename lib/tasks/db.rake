namespace :db do
  namespace :views do

    desc 'Creates the views in the DB'
    task :create => :environment do
      #Rolls up freeAwards qualifyingAwards and nonQualifyingAwards
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_awards.sql')))
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_allRewards.sql')))

      #Rolls up all purchases and redemptions of a user
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_debitsCredits.sql')))

      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_userBalances.sql')))

      #only returns active oauth tokens. They can expire periodically
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_oauth_tokens.sql')))

      #Returns everyone we currently consider to be active in intuit and in our system
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_active_intuit_accounts.sql')))

      #Adds the 10% control group for retail
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_offer_exclusions.sql')))
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
    end

    desc 'drop the stored procedures in the db'
    task :drop => :environment do
      ActiveRecord::Base.connection.execute('DROP PROCEDURE prc_getUsersWalletByWalletID')
    end
  end

  namespace :deprecated do
    desc "Remove deprecated tables and columns"
    task remove_tables_and_columns: :environment do
      #  TABLES:
      statement = <<-stmnt
        SELECT T.[name] AS [table_name], AC.[name] AS [column_name]
        FROM sys.[tables] AS T
          INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
        WHERE T.[is_ms_shipped] = 0 AND T.[name] LIKE '%_old'
      stmnt

      table_names = ActiveRecord::Base.connection.select_all(statement).map { |record|
        record["table_name"]
      }.uniq
      table_names.each do |table|
        ActiveRecord::Base.connection.execute("DROP TABLE #{table}")
      end

      # COLUMNS:
      statement = <<-stmnt
        SELECT T.[name] AS [table_name], AC.[name] AS [column_name]
        FROM sys.[tables] AS T
          INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
        WHERE T.[is_ms_shipped] = 0 AND AC.[name] LIKE '%_old'
      stmnt

      columns_and_table = ActiveRecord::Base.connection.select_all(statement)

      columns_and_table.each do |record|
        constraints = "SELECT df.name 'constraint_name', t.name 'table_name',
          c.NAME 'column_name'
          FROM sys.default_constraints df
          INNER JOIN sys.tables t ON df.parent_object_id = t.object_id
          INNER JOIN sys.columns c ON df.parent_object_id = c.object_id AND df.parent_column_id = c.column_id
          WHERE c.NAME LIKE '%#{record["column_name"]}%'"

        ActiveRecord::Base.connection.select_all(constraints).each do |constraint|
          constraint_alter = "ALTER TABLE #{record["table_name"]} DROP CONSTRAINT #{constraint["constraint_name"]}"
          ActiveRecord::Base.connection.execute(constraint_alter)
        end

        column_alter = "ALTER TABLE #{record["table_name"]} DROP COLUMN #{record["column_name"]}"
        ActiveRecord::Base.connection.execute(column_alter)
      end
    end

    desc "Remove temporary tables"
    task remove_temporary_tables: :environment do
      statement = <<-stmnt
        SELECT T.[name] AS [table_name], AC.[name] AS [column_name]
        FROM sys.[tables] AS T
          INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
        WHERE T.[is_ms_shipped] = 0 AND T.[name] LIKE 'tmp%'
      stmnt

      tmp_table_records = ActiveRecord::Base.connection.select_all(statement).map { |record|
        record["table_name"]
      }.uniq

      tmp_table_records.each do |table_name|
        ActiveRecord::Base.connection.execute("DROP TABLE #{table_name}")
      end
    end
  end

end
