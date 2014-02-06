export RAILS_ENV=test

cd gems/plink_analytics && bundle install --deployment --path vendor/bundle && bundle exec rspec spec && cd ../..
STATUS=$((STATUS + $?))

bundle exec rspec spec/controllers --tag ~flaky --tag ~skip_in_build
STATUS=$((STATUS + $?))

bundle exec rspec spec/helpers --tag ~flaky --tag ~skip_in_build
STATUS=$((STATUS + $?))

bundle exec rspec spec/mailers --tag ~flaky --tag ~skip_in_build
STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS

