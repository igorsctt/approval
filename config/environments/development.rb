# Development environment configuration

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.variant_processor = :mini_magick

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Use an evented file watcher to automatically reload files as they change.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # ActionMailer configuration for development
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: ENV.fetch('APPROVAL_URL', 'http://localhost:3000') }
  
  # Use letter_opener for email previews in development
  config.action_mailer.delivery_method = :letter_opener if defined?(LetterOpener)
  
  # Configure ActionMailer SMTP settings
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_HOST', 'localhost'),
    port: ENV.fetch('SMTP_PORT', 1025).to_i,
    domain: ENV.fetch('SMTP_DOMAIN', 'localhost'),
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: ENV.fetch('SMTP_AUTHENTICATION', 'plain'),
    enable_starttls_auto: ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', 'false') == 'true'
  }

  # Logging configuration
  config.log_level = ENV.fetch('LOG_LEVEL', 'debug').to_sym
  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
  end

  # Enable color in logs
  config.colorize_logging = true

  # Debug mode for assets
  config.assets.debug = true
  config.assets.quiet = true

  # Suppress rendering of X-Runtime header
  config.force_ssl = false

  # Allow connections from Docker containers
  config.web_console.permissions = '0.0.0.0/0'
  
  # Disable host checking for development
  config.hosts.clear
  
  # Enable detailed query logging
  if defined?(Mongoid)
    Mongoid.logger.level = Logger::DEBUG
    Mongo::Logger.logger.level = Logger::DEBUG
  end
end
