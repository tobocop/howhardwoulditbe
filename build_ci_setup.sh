touch config/database.yml
echo -e "test:\n adapter: $DB_ADAPTER\n database: $CONNECTION_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \nredshift_test:\n adapter: $DB_ADAPTER\n database: $CONNECTION_DB_NAME\n host: $DB_HOST\n username: $DB_USERNAME\n password: $DB_PASSWORD\n \n" > config/database.yml
cp config/database.yml gems/plink/spec/dummy/config/database.yml
cp config/database.yml gems/plink_admin/spec/dummy/config/database.yml

touch config/lyris.yml
echo -e "test:\n site_id: $LYRIS_SITE_ID\n password: $LYRIS_PASSWORD\n mailing_list_id: $LYRIS_MAILING_LIST_ID" > config/lyris.yml

touch config/gigya_keys.yml
echo -e "test:\n gigya_api_key: $GIGYA_API_KEY\n gigya_secret: $GIGYA_SECRET" > config/gigya_keys.yml

touch gems/gigya/integration_spec/support/gigya_keys.yml
echo -e "api_key: $GIGYA_API_KEY\nsecret: $GIGYA_SECRET" > gems/gigya/integration_spec/support/gigya_keys.yml

touch config/intuit.yml
echo -e "test:\n issuer_id: $INTUIT_ISSUER_ID\n consumer_key: $INTUIT_CONSUMER_KEY\n consumer_secret: $INTUIT_CONSUMER_SECRET\n certificate_path: `pwd`/config/sdgidfedapp11.corp.intuit.net.key" > config/intuit.yml

touch config/sendgrid.yml
echo -e "test:\n username: user\n password: pass" > config/sendgrid.yml

touch config/tango.yml
echo -e "test:\n base_url: $TANGO_BASE_URL\n username: $TANGO_USERNAME\n password: $TANGO_PASSWORD" > config/tango.yml

touch config/salt.yml
echo -e "test:\n salt: stuff\n" > config/salt.yml

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
