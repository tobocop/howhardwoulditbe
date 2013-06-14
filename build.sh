#! /bin/bash

set -e

./approve_gems.sh

license_finder
STATUS=$?

rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
