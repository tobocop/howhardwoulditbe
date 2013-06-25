source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'tiny_tds', '0.5.1'
gem 'activerecord-sqlserver-adapter', '3.2.10'
gem 'haml-rails', '~> 0.4'

gem 'thin'
gem 'jquery-rails', '~> 3.0.1'

gem 'gigya', path: 'gems/gigya'
gem 'plink', path: 'gems/plink'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.13.2'
  gem 'capybara', '~> 2.1.0'
  gem 'license_finder', git: 'git://github.com/pivotal/LicenseFinder.git', require: false
  gem 'jasmine', '~> 1.3.2'
end

group :test do
  gem 'capybara', '~> 2.1.0'
  gem 'launchy', '2.3.0'
  gem 'database_cleaner', '~> 1.0.1'
  gem 'selenium-webdriver', '2.33.0'
end
