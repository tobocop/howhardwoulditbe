#! /bin/bash

set -e

sudo apt-get install freetds-dev -y
bundle install --deployment --path vendor/bundle
touch config/database.yml
echo -e "test:\n adapter: sqlserver\n database: plink_test\n host: qa-plinkdb1-rds.cct4wdg0zsjg.us-east-1.rds.amazonaws.com\n username: plinkadmin\n password: ekVNMrXW_-mOfcIWXH80I9\n dsn: Provider=SQLOLEDB;Data Source=SCADA\SQLEXPRESS;UID=plinkadmin;ekVNMrXW_-mOfcIWXH80I9;Initial Catalog=plink_test;" > config/database.yml

./approve_gems.sh

license_finder
STATUS=$?

RAILS_ENV=test bundle exec rake db:test:prepare

STATUS=$((STATUS + $?))

echo "The build exited with $STATUS"
exit $STATUS
