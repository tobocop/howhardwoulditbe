set_default :ruby_version, '1.9.3-p392'

namespace :rbenv do
  desc 'Install rbenv, Ruby, and Bundler'
  task :install, roles: :app do
    run 'wget https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer'
    run 'cat rbenv-installer | bash'
    run 'rm rbenv-installer'
    bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then
  export PATH='$HOME/.rbenv/bin:$PATH'
  eval '$(rbenv init -)'
fi
BASHRC
    put bashrc, '/tmp/rbenvrc'
    run 'cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp'
    run 'rm /tmp/rbenvrc'
    run 'mv ~/.bashrc.tmp ~/.bashrc'
    run %q{export PATH='$HOME/.rbenv/bin:$PATH'}
    run %q{eval '$(rbenv init -)'}
    run 'rbenv bootstrap-ubuntu-12-04'
    run "rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"
    run 'gem install bundler --no-ri --no-rdoc'
    run 'rbenv rehash'
  end

  desc 'Install the default Ruby version, and Bundler'
  task :install_default_ruby_version, roles: :app do
    run "rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"
    run 'gem install bundler --no-ri --no-rdoc'
    run 'rbenv rehash'
  end
end
