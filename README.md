plink-pivotal
=============

www rewrite in rails with pivotal labs.

Getting Started
---

We use a local Windows VM with SQL Server Express in development.


* install qt on host for capybara webkit
    brew install qt

* install freetds on host

    brew install freetds

	- If issues with tiny TDS gem libiconv missing
		brew install libiconv
		gem install tiny_tds -- --with-freetds-include=/usr/local/include --with-freetds-lib=/usr/local/lib --with-iconv-include=/usr/local/Cellar/libiconv/1.14/include --with-iconv-lib=/usr/local/Cellar/libiconv/1.14/lib

* add 127.0.0.1 plink.test to /etc/hosts

* bundle

* Get yml files (tango, gigya, and sendgrid)

* point database.yml at the SQL Server running on Windows VM
* cp config/database.yml gems/plink/spec/dummy/config
* cp config/database.yml gems/plink_admin/spec/dummy/config
* cp config/gigya_keys.yml gems/gigya/integration_spec/support/
    Change gigya_keys.yml in the gigya gem to look like the example

* rake db:schema:load

* rake db:udfs:create

* rake db:views:create

* rake db:seed

* open a Rails console and `Plink::UserRecord.first`. If you see a user, your dev DB is setup.

* rake db:test:prepare
* RAILS_ENV=test rake db:udfs:create
* RAILS_ENV=test rake db:views:create
* RAILS_ENV=test rake db:stored_procs:create


* ./build.sh


Generating a New Engine
===

`rails plugin new gems/[name] -GT --mountable --dummy-path=spec/dummy`


`cd gems/[name]`

add rspec-rails as a development dependency
    s.add_development_dependency 'rspec-rails', '2.13.2'

edit gemspec and remove TODOs and the MIT license
 example:

     $:.push File.expand_path('../lib', __FILE__)

     # Maintain your gem's version:
     require 'admin/version'

     # Describe your gem and declare its dependencies:
     Gem::Specification.new do |s|
       s.name        = 'admin'
       s.version     = Admin::VERSION
       s.author      = 'Plink, Inc.'
       s.summary     = 'Plink Admin engine'

       s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.rdoc']
       s.test_files = Dir['test/**/*']

       s.add_dependency 'rails', '~> 3.2.13'
       s.add_dependency 'tiny_tds', '0.5.1'
       s.add_dependency 'activerecord-sqlserver-adapter', '3.2.10'

       s.add_development_dependency 'rspec-rails', '2.13.2'
     end


- If your engine is going to have migration, make sure to add the engine's db/migrate folder to Rails migration path

        module [name]
          class Engine < ::Rails::Engine
            isolate_namespace [name]

            initializer :append_migrations do |app|
              unless app.root.to_s.match root.to_s
                app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded
              end
            end
          end
        end


- `bundle`

- `rails g rspec:install`

- edit spec_helper to point to the dummy app

from

    require File.expand_path("../../config/environment", __FILE__)

to

    require File.expand_path("../dummy/config/environment", __FILE__)

add gems/[name] to your gemfile

    gem 'admin', path: 'gems/[name]'

add new specs to the build.sh and build_ci.sh


Production Setup on Heroku
===

Running the application in production relies on the `Procfile` containing the appropriate commands for running the application. Locally, it is possible to test that the `Procfile` is correct using Foreman. To run Foreman, you'll first need to copy the example `.env` file:

    cp .env.example .env

And then run:

    foreman start

You can now access the application at:

    localhost:5000


Production Setup on EC2
===

### Ubuntu Packages

- As the `root` user on the server issue the following:
  * `apt-get update`
  * `apt-get install make curl nodejs libapache2-mod-xsendfile`
  * `apt-get install freetds-dev unixodbc-dev unixodbc-bin unixodbc`

### Accident Insurance

- Setup root terminal coloring, as root:
  * `vim /home/deployer/.bashrc` and add `PS1='\e[41;1m\u@\h: \W \e[m \$ '`
  * `source /home/deployer/.bashrc`

#### Creating `deployer`

- To create the `deployer` user with `SSH` key access, run the following as the `root` user:
  * `adduser deployer` - enter a PW for the user and matching confirmation and add these to `KeePass`
  * `su - deployer`
  * `vim /home/deployer/.bashrc` and add `PS1='\e[41;1m\u@\h: \W \e[m \$ '`
  * `source /home/deployer/.bashrc`
  * `mkdir /home/deployer/.ssh`
  * `chmod 700 /home/deployer/.ssh`
  * `ssh-keygen -t rsa` and press Enter three times or, optionally, configure a password and store it in `KeePass`
  * `cat /home/deployer/.ssh/id_rsa.pub >> /home/deployer/.ssh/authorized_keys`
  * `chown deployer:deployer /home/deployer/.ssh/authorized_keys`
  * `chmod 600 /home/deployer/.ssh/authorized_keys`
  * `exit` - should return to `root` user prompt
  * `visudo`
    - add the following lines to the bottom of the file:

      `## Allow deployer to run any commands anywhere without prompting for password
       deployer        ALL=(ALL)       NOPASSWD: ALL`
  * `exit` from `visudo`
  * `su - deployer`
  * `ssh deployer@[insert_server_IP_address_here]`
  * the above command is just for testing; it shouldn't prompt for a password
  * `sudo ls`
  * the above command also shouldn't prompt for a password
  * `exit` to get back to `deployer` user prompt that is not using `SSH`

### Enabling Users to Deploy

- Add your `SSH public key` so that you can deploy. As the `deployer` user:
  * [local ] `cat /Users/[name]/.ssh/id_rsa.pub`
  * [server] append output from last command to `vim /home/deployer/.ssh/authorized_keys`

### Installing `git`

`SSH` into the remote as the `deployer` user. Then;

- Install `git`
  * `sudo apt-get install git`

- Setup permissions on github.com:

  * `cat ~/.ssh/id_rsa.pub`
  * Open github.com preferences for the repository that the remote will use and add the public key, this can be found in the "Deploy Keys" section

### Installing Apache2

`SSH` into the remote as the `deployer` user. Then;

- Configure Apache2
  * `sudo -i`
  * `apt-get install apache2`
  * `adduser www-data` - enter a PW for the user and matching confirmation and enter it in `KeyPass`
  * `mkdir -p /var/www/plink-www`
  * `chown -R deployer:deployer /var/www/plink-www`
  * in `/etc/apache2/sites-available` create a text file named `points.plink.com`
  * copy the contents of `config/deploy/apache/points.plink.com.example` into the above file on the server
  * save and exit the file
  * `a2enmod rewrite`
  * `a2enmod proxy`
  * `a2enmod proxy_balancer`
  * `a2enmod proxy_http`
  * `a2enmod expires`
  * `a2enmod headers`

Deploying with Capistrano
===

### Some general guidelines:

* All commands documented below are issues from local Rails root directory
* All commands documented for the **default** environment, currently `review` (should never be `production`)
* To modify commands to run for a specified environment, use `cap [environment] ...` (e.g. `cap production unicorn:restart`)

### To setup the machine for running `Ruby on Rails` with `unicorn`

- Install RBEnv from local dev:
  * You can configure the `ruby` version in `config/deploy/recipes/rbenv.rb'
  * `cap rbenv:install`

- Make sure that `apache` is running:
  * `cap apache:start`

- Cap tasks for first-time setup:
   * `cap deploy:setup`
   * The above command will prompt you for all YAML file credetials: `database.yml`, `sendgrid.yml`, `gigya_keys.yml`, `tango.yml`
   * `cap deploy:check`
   * The above command should return `You appear to have all necessary dependencies installed`
   * `cap deploy:cold` (you will not want to use this command unless this is a first deployment, use `cap deploy` instead)
   * `cap unicorn:restart` (you may need to issue `cap unicorn:start`)

- **_DISCLAIMER_** about `unicorn`s and `rubygems` : Whenever a release incldues a gem installation, you will want to keep an eye on `current/log/unicorn_access.log` and the  `unicorn_error.log` as well. Sometimes gem installations can cause the unicorns to spin into a `kill/spawn` (infinite) loop. To remedy this, issue:
   * `cap unicorn:stop`
   * `cap unicorn:start`

- Once this has been done, to deploy the application: From the Rails root directory on local machine:
   * `cap deploy:update`
   * `cap unicorn:restart`

### Quick Reference: `cap` commands
   * Run `cap -T` to see what tasks Capistrano knows about. These all have descriptions in the recipes and should describe what the task will do on the remote.
   * All `recipes` can be found at `config/deploy/recipes/`
   * `cap apache:{restart:start:stop}`
   * `cap unicorn:{restart:start:stop}`
