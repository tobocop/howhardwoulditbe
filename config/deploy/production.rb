server '54.221.228.117', :app, :web, :db, primary: true

set :rails_env, 'production'
set :unicorn_env, 'production'

set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
