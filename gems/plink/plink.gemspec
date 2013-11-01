$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'plink/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'plink'
  s.author      = 'plink'
  s.version     = Plink::VERSION
  s.summary     = 'Plink gem.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '3.2.13'
  s.add_dependency 'tiny_tds', '0.5.1'
  s.add_dependency 'activerecord-sqlserver-adapter', '3.2.10'
  s.add_dependency 'tango'
  s.add_dependency 'exceptional'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'tire'
end
