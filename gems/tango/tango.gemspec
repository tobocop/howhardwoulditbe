# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tango/version'

Gem::Specification.new do |spec|
  spec.name          = 'tango'
  spec.author        = 'plink'
  spec.version       = Tango::VERSION
  spec.summary       = %q{Tango gem}

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.13.0'
  spec.add_development_dependency 'artifice', '~> 0.6'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'pry'

  spec.add_dependency 'faraday', '~> 0.8.7'
  spec.add_dependency 'json', '~> 1.8.0'
end
