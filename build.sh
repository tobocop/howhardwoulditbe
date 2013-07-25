#! /bin/bash

export RAILS_ENV=test

set -e

echo "RUNNING PLINK ADMIN GEM BUILD"
cd gems/plink_admin && rspec spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING GIGYA GEM BUILD"
cd gems/gigya && rspec spec && rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING TANGO GEM BUILD"
cd gems/tango && rspec spec && rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING PLINK GEM BUILD"
cd gems/plink && rspec spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING JASMINE BUILD"
bundle exec rake jasmine:ci
STATUS=$((STATUS + $?))

echo "RUNNING RAILS APP BUILD"
bundle exec rake db:migrate
bundle exec rake db:test:prepare
bundle exec rake db:udfs:create
bundle exec rake db:views:create
bundle exec rspec spec --tag ~skip_in_build
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
