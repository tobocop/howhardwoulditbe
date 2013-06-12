#! /bin/bash

set -e

license_finder
STATUS=$?

rspec spec
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
