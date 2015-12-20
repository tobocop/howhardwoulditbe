export RAILS_ENV=test

bundle exec rspec spec/features --tag ~flaky --tag ~skip_in_build
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS

