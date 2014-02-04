source 'https://rubygems.org'

gem 'rails', '3.2.16'
gem 'tiny_tds', '0.6.1'
gem 'activerecord-sqlserver-adapter', '3.2.10'
gem 'activerecord-redshift-adapter'
gem 'haml-rails', '~> 0.4'

gem 'thin'
gem 'jquery-rails', '~> 3.0.1'
gem 'delayed_job_active_record', '~> 4.0.0'
gem 'daemons', '~> 1.1.9'
gem 'nokogiri',  '~> 1.6.0'

gem 'gigya', path: 'gems/gigya'
gem 'plink', path: 'gems/plink'
gem 'tango', path: 'gems/tango'
gem 'plink_admin', path: 'gems/plink_admin'

gem 'aggcat', git: 'https://github.com/cloocher/aggcat'
gem 'tire'
gem 'exceptional'
gem 'librato-rails'
gem 'statsd-instrument'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'foreman'
  gem 'capistrano', '~> 2.15.5'
  gem 'capistrano-ext'
end

group :development, :test do
  gem 'rspec-rails', '~>2.14'
  gem 'jasmine', '~> 1.3.2'
  gem 'quiet_assets'
  gem 'pry'
end

group :test do
  gem 'capybara', '~> 2.1.0'
  gem 'capybara-webkit', '~> 1.0.0'
  gem 'launchy', '2.3.0'
  gem 'database_cleaner', '~> 1.0.1'
  gem 'selenium-webdriver', '2.38.0'
  gem 'rspec-retry'
  gem 'faraday'
  gem 'vcr'
end

group :production, :review do
  gem 'newrelic_rpm'
end

group :production do
  gem 'unicorn'
  gem 'execjs'
end
