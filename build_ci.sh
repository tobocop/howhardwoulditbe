#! /bin/bash

set -e

sudo apt-get install freetds-dev -y

export RAILS_ENV=test

bundle install --deployment --path vendor/bundle

./approve_gems.sh

bundle exec license_finder rescan -q
STATUS=$?

bundle exec rake db:test:prepare
bundle exec rake db:create_views
bundle exec rspec spec
STATUS=$((STATUS + $?))

cd gems/gigya && bundle install --deployment --path vendor/bundle && bundle exec rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
