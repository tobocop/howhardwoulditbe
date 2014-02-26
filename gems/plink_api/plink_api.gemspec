$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plink_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plink_api"
  s.version     = PlinkApi::VERSION
  s.author      = "Plink, Inc."
  s.summary     = "Plink API Gem"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '3.2.16'
  s.add_dependency 'tiny_tds', '0.6.1'
  s.add_dependency 'activerecord-sqlserver-adapter', '3.2.10'
  s.add_dependency 'griddler', '~> 0.6.3'
  s.add_dependency 'aws-sdk', '~> 1.34.0'
  s.add_dependency 'tire'


  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'shoulda-matchers'
end
