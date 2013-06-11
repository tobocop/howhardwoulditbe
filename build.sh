#! /bin/bash

rspec spec
STATUS=$?

echo "The build exited with $STATUS"
exit $STATUS


