plink-pivotal
=============

www rewrite in rails with pivotal labs.

Getting Started
---

We use a local Windows VM with SQL Server Express in development.

* install freetds on host

    brew install freetds

	- If issues with tiny TDS gem libiconv missing
		brew install libiconv
		gem install tiny_tds -- --with-freetds-include=/usr/local/include --with-freetds-lib=/usr/local/lib --with-iconv-include=/usr/local/Cellar/libiconv/1.14/include --with-iconv-lib=/usr/local/Cellar/libiconv/1.14/lib

* point database.yml at the SQL Server running on Windows VM

* bundle

* rake db:schema:load

* rake db:udfs:create

* rake db:views:create

* rake db:seed

* open a Rails console and `User.first`. If you see a user, you did it.


Generating a New Engine
===

`rails plugin new gems/[name] --mountable`

`cd gems/[name]`

`rm .gitignore`

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

       s.add_development_dependency 'sqlite3'
       s.add_development_dependency 'rspec-rails', '2.13.2'
     end


- `bundle`

- `rails g rspec:install`

`cp -r test/dummy spec/`

`rm -r test`

- edit Rakefile to point to correct dummy app

change

    APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)

to

    APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)

- edit spec_helper to point to the dummy app

from

    require File.expand_path("../../config/environment", __FILE__)

to

    require File.expand_path("../dummy/config/environment", __FILE__)

add gems/[name] to your gemfile

    gem 'admin', path: 'gems/[name]'


add new specs to the build.sh and build_ci.sh

