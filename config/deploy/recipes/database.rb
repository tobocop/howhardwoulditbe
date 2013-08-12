set_default :production_db_database do
  Capistrano::CLI.password_prompt 'DB name: '
end

set_default :production_db_user do
  Capistrano::CLI.password_prompt 'DB user: '
end

set_default :production_db_password do
  Capistrano::CLI.password_prompt 'DB password: '
end

set_default :production_db_host do
  Capistrano::CLI.password_prompt 'DB host: '
end

set_default :production_db_port, '1433'

namespace :db do
  desc 'Generate the database.yml configuration file.'
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "database.yml.erb", "#{shared_path}/config/database.yml"
  end
  after 'deploy:setup', 'db:setup'

  desc 'Load the schema using schema.rb and then seed the DB'
  task :schema_load, roles: :app do
    run "cd #{current_path}; bundle exec rake db:schema:load RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake db:udfs:create RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake db:views:create RAILS_ENV=#{rails_env}"
  end
  after 'db:setup', 'db:schema_load'

  desc 'Symlink the database.yml file into latest release'
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after 'deploy:finalize_update', 'db:symlink'

  desc 'Symlink the database.yml file into current release'
  task :symlink_current, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
  end

  desc 'load database with seed data'
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end

  desc 'drop database'
  task :drop do
    run "cd #{current_path}; bundle exec rake db:drop RAILS_ENV=#{rails_env}"
  end

  desc 'migrate database'
  task :migrate do
    run "cd #{current_path}; bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
  end
  after 'deploy:update', 'db:migrate'
end
