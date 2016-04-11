set_default :unicorn_log, "#{current_path}/log/"
set_default :unicorn_workers, 3
set_default :web_timeout, Integer(15)
set_default :unicorn_user, 'deployer'
set_default :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
set_default :unicorn_config, "#{current_path}/config/unicorn.rb"

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/sockets"
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
    template "unicorn_init.erb", "/tmp/unicorn_init"
    run "chmod +x /tmp/unicorn_init"
    run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"
    run "#{sudo} update-rc.d -f unicorn_#{application} defaults"
  end
  after "deploy:setup", "unicorn:setup"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "service unicorn_#{application} #{command}"
    end
  end

  desc "Generate the unicorn configuration files"
  task :setup, roles: :app do
    template "unicorn_init.erb", "#{shared_path}/config/unicorn_init.sh"
    sudo "ln -nfs #{shared_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    sudo "chmod +x /etc/init.d/unicorn_#{application}"
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
