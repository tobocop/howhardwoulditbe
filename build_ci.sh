#! /bin/bash

set -e

time sudo apt-get install freetds-dev -y


time bundle install --deployment --path vendor/bundle


time bundle exec rake db:test:load
time bundle exec rake db:udfs:create
time bundle exec rake db:views:create

cd gems/plink_admin && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/gigya && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && bundle exec rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/tango && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && bundle exec rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/plink && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

bundle exec rake jasmine:ci
STATUS=$((STATUS + $?))

bundle exec rspec spec --tag ~flaky --tag ~skip_in_build
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
