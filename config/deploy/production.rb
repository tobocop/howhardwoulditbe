server 'ec2-50-19-182-7.compute-1.amazonaws.com', :app, :web, :db, primary: true

set :rails_env, 'production'
set :unicorn_env, 'production'

set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
