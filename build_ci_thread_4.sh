export RAILS_ENV=test

bundle exec rspec spec/lib --tag ~flaky --tag ~skip_in_build
STATUS=$((STATUS + $?))

bundle exec rspec spec/models --tag ~flaky --tag ~skip_in_build
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS

