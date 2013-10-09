touch config/database.yml
echo -e "test:\n adapter: $DB_ADAPTER\n database: $CONNECTION_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \nredshift_test:\n adapter: $DB_ADAPTER\n database: $CONNECTION_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \n" > config/database.yml
cp config/database.yml gems/plink/spec/dummy/config/database.yml
cp config/database.yml gems/plink_admin/spec/dummy/config/database.yml

touch config/gigya_keys.yml
echo -e "test:\n gigya_api_key: $GIGYA_API_KEY\n gigya_secret: $GIGYA_SECRET" > config/gigya_keys.yml
touch gems/gigya/integration_spec/support/gigya_keys.yml
echo -e "api_key: $GIGYA_API_KEY\nsecret: $GIGYA_SECRET" > gems/gigya/integration_spec/support/gigya_keys.yml
touch config/sendgrid.yml
echo -e "test:\n username: user\n password: pass" > config/sendgrid.yml
touch config/tango.yml
echo -e "test:\n base_url: $TANGO_BASE_URL\n username: $TANGO_USERNAME\n password: $TANGO_PASSWORD" > config/tango.yml
sudo sh -c "echo '127.0.0.1 plink.test' >> /etc/hosts"
export RAILS_ENV=test

sudo apt-get install freetds-dev -y

bundle install --deployment --path vendor/bundle

bundle exec rake db:create_ms_sql[$THREAD_DB_NAME]

echo -e "test:\n adapter: $DB_ADAPTER\n database: $THREAD_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \nredshift_test:\n adapter: $DB_ADAPTER\n database: $CONNECTION_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \n" > config/database.yml
cp config/database.yml gems/plink/spec/dummy/config/database.yml
cp config/database.yml gems/plink_admin/spec/dummy/config/database.yml

bundle exec rake db:test:load
bundle exec rake db:udfs:create
bundle exec rake db:views:create
