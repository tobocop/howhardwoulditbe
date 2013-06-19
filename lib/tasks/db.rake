namespace :db do
  desc 'Creates the stored procs in the DB'
  task :create_views => :environment do
    ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_awards.sql')))
    ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_allRewards.sql')))
    ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_debitsCredits.sql')))
    ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_vw_userBalances.sql')))
  end
end
