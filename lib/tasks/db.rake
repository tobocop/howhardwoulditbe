namespace :db do
  desc 'Creates the stored procs in the DB'
  task :create_views => :environment do
    ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'create_views.sql')))
  end
end
