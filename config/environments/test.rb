PlinkPivotal::Application.configure do


  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  config.action_mailer.delivery_method = :test

  config.action_mailer.default_url_options = { :host => "plink.test:58891" }

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  sendgrid_keys = YAML.load_file(Rails.root.join('config', 'sendgrid.yml'))[Rails.env]
  config.action_mailer.smtp_settings = {
      :address        => 'smtp.sendgrid.net',
      :port           => 25,
      :domain         => 'plink.com',
      :authentication => :plain,
      :user_name      => sendgrid_keys['username'],
      :password       => sendgrid_keys['password']
  }

  config.contact_email_address = 'contactus@example.com'

  gigya_keys = YAML.load_file(Rails.root.join('config', 'gigya_keys.yml'))[Rails.env]
  ENV['GIGYA_API_KEY'] = gigya_keys['gigya_api_key']
  ENV['GIGYA_SECRET'] = gigya_keys['gigya_secret']

  tango_keys = YAML.load_file(Rails.root.join('config', 'tango.yml'))[Rails.env]
  ENV['TANGO_BASE_URL'] = tango_keys['base_url']
  ENV['TANGO_USERNAME'] = tango_keys['username']
  ENV['TANGO_PASSWORD'] = tango_keys['password']
end
