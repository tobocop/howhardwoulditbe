#! /bin/bash

export RAILS_ENV=test

set -e

bundle exec rspec spec
STATUS=$((STATUS + $?))

rspec integration_spec
STATUS=$((STATUS + $?))

echo "Gigya build exited with $STATUS"
exit $STATUS
