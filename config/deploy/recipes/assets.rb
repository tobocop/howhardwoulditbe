namespace :assets do
  task :precompile, :roles => :web do
    run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} RAILS_GROUPS=assets assets:precompile --trace"
  end
  after "deploy:update", "assets:precompile"
end
