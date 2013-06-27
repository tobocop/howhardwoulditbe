#! /bin/bash

export RAILS_ENV=test

set -e

sudo apt-get install freetds-dev -y

bundle install --deployment --path vendor/bundle

bundle exec rake db:migrate
bundle exec rake db:test:prepare
bundle exec rake db:udfs:create
bundle exec rake db:views:create

./approve_gems.sh

bundle exec license_finder rescan -q
STATUS=$?

cd gems/gigya && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && bundle exec rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/plink && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

bundle exec rake jasmine:ci
STATUS=$((STATUS + $?))

bundle exec rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
