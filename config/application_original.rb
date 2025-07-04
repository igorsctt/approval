# Rails Application Configuration

require_relative "boot"

# Load individual Rails frameworks, excluding ActiveRecord
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApprovalWorkflow
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # API only mode
    config.api_only = false

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3000').split(',')
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end

    # Autoload paths
    config.autoload_paths += %W(#{config.root}/app/services)
    config.autoload_paths += %W(#{config.root}/app/serializers)

    # Time zone
    config.time_zone = 'UTC'

    # Exception handling
    config.exceptions_app = self.routes

    # Session configuration
    config.session_store :cookie_store, key: '_approval_workflow_session'
    config.session_options = {
      secure: Rails.env.production?,
      same_site: :lax,
      httponly: true
    }

    # Security
    config.force_ssl = Rails.env.production?
    
    # Generators configuration
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.stylesheets false
      g.javascripts false
      g.helper false
    end

    # ActionMailer configuration
    config.action_mailer.default_url_options = { host: ENV.fetch('APPROVAL_URL', 'http://localhost:3000') }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch('SMTP_HOST', 'smtp.gmail.com'),
      port: ENV.fetch('SMTP_PORT', 587).to_i,
      domain: ENV.fetch('SMTP_DOMAIN', 'gmail.com'),
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      authentication: 'plain',
      enable_starttls_auto: true
    }

    # Logging configuration
    config.log_level = ENV.fetch('LOG_LEVEL', 'debug').to_sym
    config.logger = ActiveSupport::Logger.new(STDOUT)
    config.logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
    end

    # Custom middleware
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
  end
end
