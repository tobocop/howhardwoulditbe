PlinkPivotal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.assets.initialize_on_precompile = false

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = { :host => "points.plink.com" }

  sendgrid_keys = YAML.load_file(Rails.root.join('config', 'sendgrid.yml'))[Rails.env]
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => 25,
    :domain         => 'plink.com',
    :authentication => :plain,
    :user_name      => sendgrid_keys['username'],
    :password       => sendgrid_keys['password']
  }

  config.contact_email_address = 'support@plink.com'

  config.force_ssl = true
end
