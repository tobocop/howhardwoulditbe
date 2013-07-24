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
