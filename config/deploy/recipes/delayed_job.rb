#Tasks from delayed/recipes
namespace :delayed_job do
  desc "Restarts our DJ default queue and named queues"
  task :restart_named_queues, roles: :app do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} script/delayed_job stop"
    run "cd #{release_path}; RAILS_ENV=#{rails_env} script/delayed_job --queue=default -i default_1 start"
    run "cd #{release_path}; RAILS_ENV=#{rails_env} script/delayed_job --queue=default -i default_2 start"
    run "cd #{release_path}; RAILS_ENV=#{rails_env} script/delayed_job --queue=intuit_account_removals -i account_removal_1 start"
    run "cd #{release_path}; RAILS_ENV=#{rails_env} script/delayed_job --queue=intuit_account_removals -i account_removal_2 start"
  end
  after 'deploy:update', 'delayed_job:restart_named_queues'
end
