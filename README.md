plink-pivotal
=============
www rewrite in rails with pivotal labs.

## Table of Contents

* [Getting Started](#getting-started)
* [Generating a New Engine](#generating-a-new-engine)
* [Production Setup on Heroku](#production-setup-on-heroku)
* [Production Setup on EC2](#production-setup-on-ec2)
  * [Ubuntu Packages](#ubuntu-packages)
  * [Accident Insurance](#accident-insurance)
  * [Creating `deployer`](#creating-deployer)
  * [Enabling Users to Deploy](#enabling-users-to-deploy)
  * [Installing `git`](#installing-git)
  * [Installing nginx](#installing-ngnix)
* [Deploying with Capistrano](#deploying-with-capistrano)
* [SSL setup](#ssl-setup)



## Getting Started
---


We use a local Windows VM with SQL Server Express in development.

---


* ####Install rbenv:
> Compatibility note: rbenv is _incompatible_ with RVM. Please make
>  sure to fully uninstall RVM and remove any references to it from
>  your shell initialization files before installing rbenv.
>
>
>##### Basic GitHub Checkout
>
>This will get you going with the latest version of rbenv and make it
>easy to fork and contribute any changes back upstream.
>
>1. Check out rbenv into `~/.rbenv`.
>
>    ~~~ sh
>    $ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
>    ~~~
>
>2. Add `~/.rbenv/bin` to your `$PATH` for access to the `rbenv`
>   command-line utility.
>
>    ~~~ sh
>    $ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
>    ~~~
>
>    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.
>
>    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.
>
>3. Add `rbenv init` to your shell to enable shims and autocompletion.
>
>    ~~~ sh
>    $ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
>    ~~~
>
>    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._
>
>4. Restart your shell so that PATH changes take effect. (Opening a new
>   terminal tab will usually do it.) Now check if rbenv was set up:
>
>    ~~~ sh
>    $ type rbenv
>    #=> "rbenv is a function"
>    ~~~
>
>5. _(Optional)_ Install [ruby-build][], which provides the
>   `rbenv install` command that simplifies the process of
>   installing new Ruby versions.
>
---


* install qt on host for capybara webkit
    `brew install qt`

* install elasticsearch
    `brew install elasticsearch`


* install freetds on host

    `brew install freetds`

    >- If issues with tiny TDS gem libiconv missing
    brew install libiconv
    gem install tiny_tds -- --with-freetds-include=/usr/local/include --with-freetds-lib=/usr/local/lib --with-iconv-include=/usr/local/Cellar/libiconv/1.14/include --with-iconv-lib=/usr/local/Cellar/libiconv/1.14/lib

* add 127.0.0.1 plink.test to /etc/hosts

* `bundle`

* Get yml files (tango, gigya, and sendgrid). They should be in Keepass.

* point `database.yml` at the SQL Server running on Windows VM
* `ln -s config/database.yml gems/plink/spec/dummy/config`
* `ln -s config/database.yml gems/plink_admin/spec/dummy/config`
* `ln -s config/gigya_keys.yml gems/gigya/integration_spec/support/`

* Change the following configuration files to look like the corresponding `.example` files:
 - `salt.yml`
 - `lryis.yml`
 - `intuit.yml`
 - `gigya_keys.yml`
 - `elasticsearch.yml`
 - `statsd.js`

* `bundle exec rake db:schema:load`

* `bundle exec rake db:udfs:create`

* `bundle exec rake db:views:create`

* `bundle exec rake db:seed`

* open a Rails console and `Plink::UserRecord.first`. If you see a user, your dev DB is setup.

* `rake db:test:prepare`
* `RAILS_ENV=test rake db:udfs:create`
* `RAILS_ENV=test rake db:views:create`
* `RAILS_ENV=test rake db:stored_procs:create`

* Add the following alaises to your `~/.bash_profile`  Zsh note: Modify your `~/.zshrc` file instead of `~/.bash_profile `
      alias elasticsearch_start="elasticsearch -f -D es.config=config/elasticsearch.yml"
      alias delayed_job_start="RAILS_ENV=development script/delayed_job start"
      alias statsd_start="node {/your/path/to}/statsd/stats.js ~/Desktop/dev/plink/config/statsd.js"

* `elasticsearch_start`
* `delayed_job_start`

* Make a dummy CF directory ie: `mkdir $HOME/Desktop/cfdummysite`
* Edit `/etc/hosts` and add `127.0.0.1  www.plink.dev`
* Edit `/etc/apache2/extra/httpd-vhosts.conf` and add (make sure `DocumentRoot` points to the dummy CF directory):
        <VirtualHost *:80>
        ServerName www.plink.dev
        DocumentRoot  **YOUR OWN PATH**/cfdummysite
        </VirtualHost>

* `touch index.html` in the dummy CF directory
* `sudo apachectl restart`
* `./build.sh`


## Generating a New Engine
---

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

symlink the database.yml to your dummy app:
`rm spec/dummy/config/database.yml`
`ln -s ../../config/database.yml spec/dummy/config/database.yml`

add gems/[name] to your gemfile

    gem 'admin', path: 'gems/[name]'

Change your dummy routes file to mount your engine to the root

Add enginge controller route fixes to your spec/support:

  module EngineControllerRoutesFix
    def get(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "GET")
    end

    # Executes a request simulating POST HTTP method and set/volley the response
    def post(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "POST")
    end

    # Executes a request simulating PUT HTTP method and set/volley the response
    def put(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "PUT")
    end

    # Executes a request simulating DELETE HTTP method and set/volley the response
    def delete(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "DELETE")
    end

    private

    def process_action(action, parameters = nil, session = nil, flash = nil, method = "GET")
      parameters ||= {}
      process(action, parameters.merge!(:use_route => :plink_admin), session, flash, method)
    end
  end

If using haml, make sure to add the require to your lib/[engine_name].rb:
require 'haml-rails'

if your engine is mountable, add it to the routes file in the outer app:
  mount PlinkAdmin::Engine => '/plink_admin'

Define a new route and write a feature spec to visit that route to make sure everything is setup correctly

add new specs to the build.sh and build_ci.sh


## Production Setup on Heroku
---

Running the application in production relies on the `Procfile` containing the appropriate commands for running the application. Locally, it is possible to test that the `Procfile` is correct using Foreman. To run Foreman, you'll first need to copy the example `.env` file:

    cp .env.example .env

And then run:

    foreman start

You can now access the application at:

    localhost:5000


## Production Setup on EC2
---

### Ubuntu Packages

- As the `root` user on the server issue the following:
  * `apt-get update`
  * `apt-get install make curl nodejs libapache2-mod-xsendfile`
  * `apt-get install freetds-dev unixodbc-dev unixodbc-bin unixodbc`

### Accident Insurance

- Setup root terminal coloring, as root:
  * `vim /home/deployer/.bashrc` and add `PS1='\e[41;1m\u@\h: \W \e[m \$ '`
  * `source /home/deployer/.bashrc`

#### Creating deployer

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

### Installing git

`SSH` into the remote as the `deployer` user. Then;

- Install `git`
  * `sudo apt-get install git`

- Setup permissions on github.com:

  * `cat ~/.ssh/id_rsa.pub`
  * Open github.com preferences for the repository that the remote will use and add the public key, this can be found in the "Deploy Keys" section

### Installing nginx

`SSH` into the remote as the `deployer` user. Then;

  * `sudo -i`
  * `apt-get install nginx`
  * `useradd -s /sbin/nologin -r nginx`
  * `usermod -a -G nginx nginx`
  * `chgrp -R nginx /var/www`
  * `chmod -R 775 /var/www`
  * `usermod -a -G nginx root`
  * `usermod -a -G nginx deployer`
  * `vim /etc/nginx/nginx.conf`
  * copy the contents of `config/deploy/nginx/nginx.conf.example` into the above file on the server
  * save and exit the file
  * `service nginx start`

## Deploying with Capistrano
---

### Some general guidelines:

* All commands documented below are issues from local Rails root directory
* All commands documented for the **default** environment, currently `review` (should never be `production`)
* To modify commands to run for a specified environment, use `cap [environment] ...` (e.g. `cap production unicorn:restart`)

### To setup the machine for running `Ruby on Rails` with `unicorn`

- Install RBEnv from local dev:
  * You can configure the `ruby` version in `config/deploy/recipes/rbenv.rb'
  * `cap rbenv:install`

- Make sure that `nginx` is running:
  * `cap nginx:start`

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
   * `cap nginx:{restart:start:stop}`
   * `cap unicorn:{restart:start:stop}`

### SSL setup
   * SCP your ther server cert up to the machine you want to install it on and move it into /etc/ngnix/ssl-certs/[yourdomain]/
   * Open the ngnix.conf and add the following lines:
    listen 443 default ssl;
    ssl_certificate /etc/nginx/ssl-certs/[yourdomain]/[name].crt;
    ssl_certificate_key /etc/nginx/ssl-certs/[yourdomain]/[name].key;
