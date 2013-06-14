#! /bin/bash

set -e

./approve_gems.sh

bundle exec license_finder rescan
STATUS=$?

rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
