# GIGYA:
set_default :gigya_api_key do
  Capistrano::CLI.password_prompt 'GIGYA api_key: '
end

set_default :gigya_secret do
  Capistrano::CLI.password_prompt 'GIGYA secret: '
end

set_default :gigya_registration_redirect_base_url do
  Capistrano::CLI.password_prompt 'GIGYA registration_redirect_base_url: '
end

# SENDGRID:
set_default :sendgrid_user do
  Capistrano::CLI.password_prompt 'SendGrid user: '
end

set_default :sendgrid_password do
  Capistrano::CLI.password_prompt 'SendGrid password: '
end

# TANGO:
set_default :tango_base_url do
  Capistrano::CLI.password_prompt 'Tango base_url: '
end

set_default :tango_user do
  Capistrano::CLI.password_prompt 'Tango user: '
end

set_default :tango_password do
  Capistrano::CLI.password_prompt 'Tango password: '
end

namespace :application_keys do
  desc "Generate the application *.yml configuration files"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "gigya_keys.yml.erb", "#{shared_path}/config/gigya_keys.yml"
    template "sendgrid.yml.erb", "#{shared_path}/config/sendgrid.yml"
    template "tango.yml.erb", "#{shared_path}/config/tango.yml"
  end
  after "deploy:setup", "application_keys:setup"

  desc "Symlink the *.yml files into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/gigya_keys.yml #{release_path}/config/gigya_keys.yml"
    run "ln -nfs #{shared_path}/config/sendgrid.yml #{release_path}/config/sendgrid.yml"
    run "ln -nfs #{shared_path}/config/tango.yml #{release_path}/config/tango.yml"
  end
  after "deploy:finalize_update", "application_keys:symlink"
end
