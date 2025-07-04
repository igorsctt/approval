# Production environment configuration

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Configuração para Railway e outros serviços cloud
  config.serve_static_assets = true if ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true  # Allow dynamic asset compilation
  config.assets.digest = false  # Disable asset digests for now

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.variant_processor = :mini_magick

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = false  # Railway/Heroku cuidam do SSL automaticamente

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = ENV.fetch('LOG_LEVEL', 'info').to_sym

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
    reconnect_attempts: 3,
    reconnect_delay: 0.5,
    reconnect_delay_max: 30
  }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "approval_workflow_production"

  # ActionMailer configuration for production
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { 
    host: ENV.fetch('APPROVAL_URL', 'https://approval.example.com'),
    protocol: 'https'
  }
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_HOST', 'smtp.gmail.com'),
    port: ENV.fetch('SMTP_PORT', 587).to_i,
    domain: ENV.fetch('SMTP_DOMAIN', 'gmail.com'),
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true,
    open_timeout: 10,
    read_timeout: 10
  }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.deprecation = :silence

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Security headers
  config.force_ssl = true
  config.ssl_options = {
    secure_cookies: true,
    hsts: {
      expires: 1.year,
      subdomains: true,
      preload: true
    }
  }

  # Session configuration
  config.session_store :cookie_store, 
    key: '_approval_workflow_session',
    secure: true,
    httponly: true,
    same_site: :strict

  # Content Security Policy
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https, "'unsafe-inline'"
    policy.style_src   :self, :https, "'unsafe-inline'"
  end

  # Specify CSP report URI
  # config.content_security_policy_report_only = true

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    ENV.fetch('APPROVAL_HOST', 'approval.example.com'),
    /.*\.herokuapp\.com/,  # Allow Heroku subdomains
    /.*\.railway\.app/,    # Allow Railway subdomains
    /.*\.up\.railway\.app/, # Allow Railway preview URLs
    /.*\.onrender\.com/    # Allow Render subdomains
  ]

  # Exception handling
  config.exceptions_app = self.routes

  # Asset compression
  config.assets.js_compressor = nil  # Disable JS compression to avoid ExecJS issues
  config.assets.css_compressor = nil # Disable CSS compression 

  # Precompile additional assets
  config.assets.precompile += %w( application.js application.css )

  # MongoDB configuration for production
  if defined?(Mongoid)
    Mongoid.logger.level = Logger::WARN
    Mongo::Logger.logger.level = Logger::WARN
  end

  # Rate limiting (if using Rack::Attack)
  # config.middleware.use Rack::Attack
end
