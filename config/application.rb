require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module PlinkPivotal
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.whitelist_attributes = true
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.precompile += ['jquery.placeholder.js']

    # Heroku deployment requirement
    config.assets.initialize_on_precompile = false
    config.default_affiliate_id = 1264

    # Set application to the same timezone as the production database; Mountain Time
    config.time_zone = 'Mountain Time (US & Canada)'
    config.active_record.default_timezone = :local
  end
end
