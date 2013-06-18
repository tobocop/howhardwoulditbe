#! /bin/bash

set -e

sudo apt-get install freetds-dev -y
bundle install --deployment --path vendor/bundle

./approve_gems.sh

bundle exec license_finder rescan
STATUS=$?

RAILS_ENV=test bundle exec rake spec
STATUS=$((STATUS + $?))

cd gems/gigya && bundle exec rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
