$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plink_analytics/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plink_analytics"
  s.version     = PlinkAnalytics::VERSION
  s.authors     = ['Plink, Inc.']
  s.summary     = "Analytics dashboard for partners or prospects"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency 'rails', '3.2.16'
  s.add_dependency 'tiny_tds', '0.6.1'
  s.add_dependency 'activerecord-sqlserver-adapter', '3.2.10'
  s.add_dependency 'haml-rails', '~> 0.4'
  s.add_dependency 'activerecord-redshift-adapter'
  s.add_dependency 'tire'
  s.add_dependency 'jasmine', '~> 1.3.2'

  s.add_development_dependency 'rspec-rails', '2.13.2'
  s.add_development_dependency 'capybara', '2.1.0'
  s.add_development_dependency 'capybara-webkit', '~> 1.0.0'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'pry'
end
