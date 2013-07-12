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
  s.add_dependency 'haml-rails', '~> 0.4'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails', '2.13.2'
end
