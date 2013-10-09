export RAILS_ENV=test

echo -e "test:\n adapter: $DB_ADAPTER\n database: $CONNECTION_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \nredshift_test:\n adapter: $DB_ADAPTER\n database: $CONNECTION_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \n" > config/database.yml
cp config/database.yml gems/plink/spec/dummy/config/database.yml
cp config/database.yml gems/plink_admin/spec/dummy/config/database.yml

bundle exec rake db:drop_ms_sql[$THREAD_DB_NAME]
