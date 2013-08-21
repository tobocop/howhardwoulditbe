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

      #Adds view for reverifications for the mobile api
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_user_has_reverifications.sql')))

      #View for rails reg to get the current active paths for a given affiliate
      ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_active_paths.sql')))
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
      puts "Removing deprecated tables:"

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
        foreign_key_alters = "SELECT
            'ALTER TABLE ' + OBJECT_NAME(parent_object_id) +
            ' DROP CONSTRAINT ' + name 'statement'
        FROM sys.foreign_keys
        WHERE referenced_object_id = object_id('#{table}')"

        ActiveRecord::Base.connection.select_all(foreign_key_alters).each do |alter|
          puts "Alter statement for table: #{alter.inspect}"
          ActiveRecord::Base.connection.execute(alter['statement'])
        end

        constraints = "SELECT df.name 'constraint_name', t.name 'table_name',
          c.NAME 'column_name'
          FROM sys.default_constraints df
          INNER JOIN sys.tables t ON df.parent_object_id = t.object_id
          INNER JOIN sys.columns c ON df.parent_object_id = c.object_id AND df.parent_column_id = c.column_id
          WHERE t.NAME LIKE '%#{table}%'"

        ActiveRecord::Base.connection.select_all(constraints).each do |constraint|
          puts "FOUND CONSTRAINT CONSTRAINT: #{constraint}"
          puts "ALTER TABLE #{constraint["table_name"]} DROP CONSTRAINT #{constraint["constraint_name"]}"
          constraint_alter = "ALTER TABLE #{constraint["table_name"]} DROP CONSTRAINT #{constraint["constraint_name"]}"
          ActiveRecord::Base.connection.execute(constraint_alter)
        end

        ActiveRecord::Base.connection.execute("DROP TABLE #{table}")
        puts "Removed table #{table}"
      end

      puts
      puts '*' * 100
      puts '*' * 100
      puts '*' * 100
      puts

      puts "Removing deprecated columns:"

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
          puts "FOUND CONSTRAINT #{constraint}"
          puts "ALTER TABLE #{constraint["table_name"]} DROP CONSTRAINT #{constraint["constraint_name"]}"
          constraint_alter = "ALTER TABLE #{constraint["table_name"]} DROP CONSTRAINT #{constraint["constraint_name"]}"
          if constraint["table_name"].present?
            begin
              ActiveRecord::Base.connection.execute(constraint_alter)
            rescue
              puts "Could not run alter!!!! #{constraint_alter}"
            end
          else
            puts "Constraint received without a table #{constraint}"
          end
        end

        foreign_keys = "SELECT
            FK.TABLE_NAME AS 'pk_table_name',
            CU.COLUMN_NAME AS 'cu_column_name',
            PK.TABLE_NAME AS 'pk_table_name',
            PT.COLUMN_NAME AS 'pk_column',
            C.CONSTRAINT_NAME 'constraint_name'
          FROM
              INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
          INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK
              ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
          INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK
              ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
          INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU
              ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
          INNER JOIN (
                      SELECT
                          i1.TABLE_NAME,
                          i2.COLUMN_NAME
                      FROM
                          INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1
                      INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2
                          ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
                      WHERE
                          i1.CONSTRAINT_TYPE = 'PRIMARY KEY'
                     ) PT
              ON PT.TABLE_NAME = PK.TABLE_NAME
          WHERE PT.COLUMN_NAME LIKE '%#{record['column_name']}%' OR CU.COLUMN_NAME LIKE '%#{record['column_name']}%'"

        ActiveRecord::Base.connection.select_all(foreign_keys).each do |foreign_key|
          puts "FOUND FOREIGH KEY #{foreign_key}"
          puts "ALTER TABLE #{foreign_key["pk_table_name"]} DROP CONSTRAINT #{foreign_key["constraint_name"]}"
          fk_alter = "ALTER TABLE #{foreign_key["pk_table_name"]} DROP CONSTRAINT #{foreign_key["constraint_name"]}"
          if foreign_key["pk_table_name"].present?
            begin
              ActiveRecord::Base.connection.execute(fk_alter)

              column_alter = "ALTER TABLE #{record["table_name"]} DROP COLUMN #{record["column_name"]}"
              ActiveRecord::Base.connection.execute(column_alter)
              puts "Removed column #{record['column_name']}"
            rescue
              puts "Could not run alter!!!! #{fk_alter}"
            end
          else
            puts "Constraint received without a table #{fk_alter}"
          end
        end
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
