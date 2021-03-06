require 'new_relic/recipes'
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require "delayed/recipes"

# User:
set :user, 'deployer'
set :use_sudo, false
# To handle forwarding of requests without prompting for a password:
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Application:
set :application, 'plink-www'
set :deploy_to, "/var/www/#{application}"

# Git:
set :scm, :git
set :repository, 'git@github.com:tobocop/howhardwoulditbe.git'
set :branch, 'master'
# Used as an alternative to :git_shallow_clone (which doesn't work with :branch):
# keep a local copy of the repo on the server:
set :deploy_via, :remote_cache

# Deployment environments
set :stages, ['review', 'production']
set :default_stage, 'review'

load 'config/deploy/recipes/base'
load 'config/deploy/recipes/database'
load 'config/deploy/recipes/nginx'
load 'config/deploy/recipes/rbenv'
load 'config/deploy/recipes/application_keys'
load 'config/deploy/recipes/unicorn'
load 'config/deploy/recipes/log'
load 'config/deploy/recipes/gems'
load 'config/deploy/recipes/delayed_job'

# Deployment Tasks:
before :deploy, 'deploy:setup'
# [ optional ] Clean up old releases on each deploy:
after 'deploy:restart', 'deploy:cleanup'
#after "deploy:update", "newrelic:notice_deployment"

# Ensure that the proper rbenv version is used:
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}
