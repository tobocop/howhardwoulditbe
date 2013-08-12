server 'ec2-23-22-37-183.compute-1.amazonaws.com', :app, :web, :db, primary: true

set :rails_env, 'review'
set :unicorn_env, 'review'

set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
