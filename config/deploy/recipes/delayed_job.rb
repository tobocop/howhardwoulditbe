#Tasks from delayed/recipes
namespace :delayed_job do
  desc "Restarts our DJ default queue and named queues"
  task :restart_named_queues, roles: :app do
    run "cd #{release_path}; #{rails_env} script/delayed_job stop"

    #Default queue
    2.times do |queue_number|
      run "cd #{release_path}; #{rails_env} script/delayed_job --queue=default -i default_#{queue_number} start"
    end

    #Intuit account removals
    2.times do |queue_number|
      run "cd #{release_path}; #{rails_env} script/delayed_job --queue=intuit_account_removals -i account_removal_#{queue_number} start"
    end

    #Institution add process calls
    5.times do |queue_number|
      run "cd #{release_path}; #{rails_env} script/delayed_job --queue=intuit_authentication -i intuit_authentication_#{queue_number} start"
    end

  end
  #after 'deploy:update', 'delayed_job:restart_named_queues'
end
