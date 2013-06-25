#! /bin/bash

export RAILS_ENV=test

set -e

cd gems/gigya && rspec spec && rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/plink && rspec spec && cd ../..
STATUS=$((STATUS + $?))

bundle exec rake jasmine:ci
STATUS=$((STATUS + $?))

bundle exec rake db:migrate
rake db:test:prepare
rake db:udfs:create
rake db:views:create
bundle exec rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
