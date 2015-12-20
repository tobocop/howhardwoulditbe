server 'ec2-54-201-102-186.us-west-2.compute.amazonaws.com', :app, :web, :db, primary: true

set :rails_env, 'review'
set :unicorn_env, 'review'

set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
