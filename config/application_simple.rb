require_relative "boot"

# Load Rails components excluding ActiveRecord
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/railtie"
require "sprockets/railtie"

# Load Mongoid
require "mongoid"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module ApprovalWorkflow
  class Application < Rails::Application
    # Configuration for the application
    config.load_defaults 7.2

    # Disable ActiveRecord since we're using MongoDB
    config.active_record.verbose_schema_dumps = false if defined?(ActiveRecord)

    # API configuration
    config.api_only = false

    # Time zone
    config.time_zone = 'UTC'

    # Load custom libraries
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app', 'services')
    config.autoload_paths << Rails.root.join('app', 'serializers')

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
      end
    end

    # Session configuration
    config.session_store :cookie_store, key: '_approval_workflow_session'

    # Security configuration
    config.force_ssl = false
    config.ssl_options = { redirect: false }

    # Logger configuration
    config.log_level = :info
    config.log_tags = [:request_id, :remote_ip]

    # Generator configuration
    config.generators do |g|
      g.test_framework :rspec
      g.orm :mongoid
      g.stylesheets false
      g.javascripts false
      g.helper false
    end

    # Middleware configuration
    config.middleware.use ActionDispatch::ContentSecurityPolicy::Middleware
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # Asset configuration
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'images')
    config.assets.paths << Rails.root.join('app', 'assets', 'stylesheets')
    config.assets.paths << Rails.root.join('app', 'assets', 'javascripts')

    # Mongoid configuration
    Mongoid.load!(Rails.root.join('config', 'mongoid.yml'), Rails.env)
  end
end
