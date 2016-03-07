server '52.37.89.116', :app, :web, :db, primary: true

set :rails_env, 'production'
set :unicorn_env, 'production'

set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
