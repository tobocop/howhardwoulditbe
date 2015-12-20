$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'plink_admin/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'plink_admin'
  s.version     = PlinkAdmin::VERSION
  s.authors     = ['Plink, Inc.']
  s.summary     = 'PlinkAdmin engine.'

  s.files = Dir["{app,config,db,lib}/**/*"] + ['Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '3.2.16'
  s.add_dependency 'devise', '2.2.4'
  s.add_dependency 'tiny_tds', '0.7.0'
  s.add_dependency 'activerecord-sqlserver-adapter', '3.2.13'
  s.add_dependency 'haml-rails', '~> 0.4'
  s.add_dependency 'activerecord-redshift-adapter'
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'tire'

  s.add_development_dependency 'rspec-rails', '2.13.2'
  s.add_development_dependency 'capybara', '2.1.0'
  s.add_development_dependency 'capybara-webkit', '~> 1.0.0'
  s.add_development_dependency 'launchy', '2.3.0'
end
