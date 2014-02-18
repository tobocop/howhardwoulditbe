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

# NEWRELIC:
set_default :plink_newrelic_license_key do
  Capistrano::CLI.password_prompt 'NewRelic License Key: '
end

set_default :newrelic_application_name do
  Capistrano::CLI.password_prompt 'NewRelic Application Name: '
end

# EXCEPTIONAL:
set_default :exceptional_api_key do
  Capistrano::CLI.password_prompt 'Exceptional Application Key: '
end

# LIBRATO:
set_default :librato_user do
  Capistrano::CLI.password_prompt 'Librato user: '
end

set_default :librato_token do
  Capistrano::CLI.password_prompt 'Librato token: '
end

namespace :application_keys do
  desc "Generate the application *.yml configuration files"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "gigya_keys.yml.erb", "#{shared_path}/config/gigya_keys.yml"
    template "sendgrid.yml.erb", "#{shared_path}/config/sendgrid.yml"
    template "tango.yml.erb", "#{shared_path}/config/tango.yml"
    template "newrelic.yml.erb", "#{shared_path}/config/newrelic.yml"
    template "exceptional.yml.erb", "#{shared_path}/config/exceptional.yml"
    template "librato.yml.erb", "#{shared_path}/config/librato.yml"
  end
  after "deploy:setup", "application_keys:setup"

  desc "Symlink the *.yml files into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/gigya_keys.yml #{release_path}/config/gigya_keys.yml"
    run "ln -nfs #{shared_path}/config/sendgrid.yml #{release_path}/config/sendgrid.yml"
    run "ln -nfs #{shared_path}/config/tango.yml #{release_path}/config/tango.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/exceptional.yml #{release_path}/config/exceptional.yml"
    run "ln -nfs #{shared_path}/config/lyris.yml #{release_path}/config/lyris.yml"
    run "ln -nfs #{shared_path}/config/elasticsearch.yml #{release_path}/config/elasticsearch.yml"
    run "ln -nfs #{shared_path}/config/intuit.yml #{release_path}/config/intuit.yml"
    run "ln -nfs #{shared_path}/config/salt.yml #{release_path}/config/salt.yml"
    run "ln -nfs #{shared_path}/config/librato.yml #{release_path}/config/librato.yml"
    run "ln -nfs #{shared_path}/config/aws.yml #{release_path}/config/aws.yml"
  end
  after "deploy:finalize_update", "application_keys:symlink"

  task :setup_lyris, roles: :app do
    set_default :lyris_site_id do
      Capistrano::CLI.password_prompt 'Lyris site id: '
    end

    set_default :lyris_password do
      Capistrano::CLI.password_prompt 'Lyris password: '
    end

    set_default :lyris_mailing_list_id do
      Capistrano::CLI.password_prompt 'Lyris mailing list id: '
    end

    template "lyris.yml.erb", "#{shared_path}/config/lyris.yml"
  end
  after "application_keys:setup", "application_keys:setup_lyris"

  task :setup_intuit, roles: :app do
    set_default :intuit_issuer_id do
      Capistrano::CLI.password_prompt 'Intuit issuer_id: '
    end
    set_default :intuit_consumer_key do
      Capistrano::CLI.password_prompt 'Intuit consumer_key: '
    end
    set_default :intuit_consumer_secret do
      Capistrano::CLI.password_prompt 'Intuit consumer_secret: '
    end
    set_default :intuit_certificate_path do
      Capistrano::CLI.password_prompt 'Intuit certificate_path: '
    end

    template "intuit.yml.erb", "#{shared_path}/config/intuit.yml"
  end
  after "application_keys:setup", "application_keys:setup_intuit"

  task :setup_aws, roles: :app do
    set_default :aws_access_key_id do
      Capistrano::CLI.password_prompt 'AWS Access Key ID: '
    end
    set_default :aws_secret_access_key do
      Capistrano::CLI.password_prompt 'AWS Secret Access Key: '
    end

    template "intuit.yml.erb", "#{shared_path}/config/aws.yml"
  end
  after "application_keys:setup", "application_keys:setup_aws"
end
