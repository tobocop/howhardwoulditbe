export RAILS_ENV=test
bundle exec rake jasmine:ci
STATUS=$((STATUS + $?))

cd gems/plink_admin && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/gigya && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && bundle exec rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/tango && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && bundle exec rspec integration_spec && cd ../..
STATUS=$((STATUS + $?))

cd gems/plink && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
