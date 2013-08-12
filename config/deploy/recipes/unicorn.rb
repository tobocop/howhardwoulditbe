set_default :unicorn_log, "#{current_path}/log/"
set_default :unicorn_workers, 3
set_default :web_timeout, 15

namespace :unicorn do
  def pid_path
    "#{shared_path}/pids/unicorn.pid"
  end

  def socket_path
    "#{shared_path}/sockets/unicorn.sock"
  end

  def check_pid_path_then_run(command)
    run <<-CMD
      if [ -s #{pid_path} ]; then
        #{command}
      else
        echo "Unicorn master worker wasn't found, possibly wasn't started at all. Try run unicorn:start first";
      fi
    CMD
  end

  desc "Starts the Unicorn server"
  task :start do
    run "mkdir -p #{File.dirname(pid_path)}"
    run "mkdir -p #{File.dirname(socket_path)}"
    run <<-CMD
      if [ ! -s #{pid_path} ]; then
        cd #{current_path} ; bundle exec unicorn -c #{current_path}/config/unicorn.rb -p 5000 -D -E #{unicorn_env};
      else
        echo "Unicorn is already running at PID: `cat #{pid_path}`";
      fi
    CMD
  end

  desc "Stops Unicorn server"
  task :stop do
    check_pid_path_then_run "kill -s QUIT `cat #{pid_path}`;"
  end

  desc "Hard stops Unicorn server by removing the pid file as well as killing the process"
  task :hard_stop do
    check_pid_path_then_run "kill -s QUIT `cat #{pid_path}`;"
    run "rm #{pid_path}"
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :roles => :app, :except => { :no_release => true } do
    check_pid_path_then_run "kill -USR2 `cat #{pid_path}`;"
  end

  desc "Generate the unicorn configuration files"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", "#{shared_path}/config/unicorn.rb"
  end
  after "deploy:setup", "unicorn:setup"

  desc "Symlink the unicorn config into the release path"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
  end
  after "deploy:finalize_update", "unicorn:symlink"

  desc "Symlink the unicorn config into the current release"
  task :symlink_current, roles: :app do
    run "ln -nfs #{shared_path}/config/unicorn.rb #{current_path}/config/unicorn.rb"
  end

end
