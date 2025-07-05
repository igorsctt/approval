require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApprovalWorkflow
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Time zone
    config.time_zone = 'America/Sao_Paulo'

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Asset configuration
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'images')
    config.assets.paths << Rails.root.join('app', 'assets', 'stylesheets')
    config.assets.paths << Rails.root.join('app', 'assets', 'javascripts')

    # Load custom libraries
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app', 'services')
    config.autoload_paths << Rails.root.join('app', 'serializers')

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 credentials: false
      end
    end

    # Session configuration
    config.session_store :cookie_store, key: '_approval_workflow_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # Security configuration
    config.force_ssl = false
    config.ssl_options = { redirect: false }

    # Logger configuration
    config.log_level = :info
    config.log_tags = %i[request_id remote_ip]

    # Generator configuration
    config.generators do |g|
      g.test_framework :rspec
      g.orm :mongoid
      g.stylesheets true
      g.javascripts true
      g.helper false
    end

    # Hosts configuration for development
    config.hosts.clear if Rails.env.development?
  end
end
