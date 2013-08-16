#! /bin/bash

export RAILS_ENV=test

set -e

echo "TEST SETUP"
bundle exec rake db:migrate
bundle exec rake db:test:prepare
bundle exec rake db:udfs:create
bundle exec rake db:views:create

echo "RUNNING PLINK ADMIN GEM BUILD"
cd gems/plink_admin && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING GIGYA GEM BUILD"
cd gems/gigya && bundle exec rspec spec && bundle exec rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING TANGO GEM BUILD"
cd gems/tango && bundle exec rspec spec && bundle exec rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING PLINK GEM BUILD"
cd gems/plink && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

echo "RUNNING JASMINE BUILD"
bundle exec rake jasmine:ci
STATUS=$((STATUS + $?))

echo "RUNNING RAILS APP BUILD"
bundle exec rspec spec --tag ~skip_in_build
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
