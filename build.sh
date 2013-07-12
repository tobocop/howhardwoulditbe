#! /bin/bash

export RAILS_ENV=test

set -e

echo "RUNNING ADMIN GEM BUILD"
cd gems/admin && rspec spec && cd ../..
STATUS=$((STATUS + $?))

echo "\n\n"

echo "RUNNING GIGYA GEM BUILD"
cd gems/gigya && rspec spec && rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

echo "\n\n"

echo "RUNNING TANGO GEM BUILD"
cd gems/tango && rspec spec && rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

echo "\n\n"

echo "RUNNING PLINK GEM BUILD"
cd gems/plink && rspec spec && cd ../..
STATUS=$((STATUS + $?))

echo "\n\n"

echo "RUNNING JASMINE BUILD"
bundle exec rake jasmine:ci
STATUS=$((STATUS + $?))

echo "\n\n"

echo "RUNNING RAILS APP BUILD"
bundle exec rake db:migrate
rake db:test:prepare
rake db:udfs:create
rake db:views:create
bundle exec rspec spec
STATUS=$((STATUS + $?))

echo "\n\n"

echo "The build exited with $STATUS"
exit $STATUS
