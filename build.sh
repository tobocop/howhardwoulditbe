#! /bin/bash

export RAILS_ENV=test

set -e

rake db:test:prepare
rake db:create_views
bundle exec rspec spec
STATUS=$((STATUS + $?))

cd gems/gigya && bundle exec rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
