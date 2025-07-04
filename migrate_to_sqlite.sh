#!/bin/bash

echo "🔄 Migrando projeto para SQLite..."

# Backup do Gemfile original
cp Gemfile Gemfile.mongoid.backup

# Criar novo Gemfile para SQLite
cat > Gemfile << 'EOF'
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.2.0'

# Use SQLite as the database for Active Record
gem 'sqlite3', '~> 1.4'

# Use Puma as the app server
gem 'puma', '~> 6.0'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'

# Turbo for fast page navigation
gem 'turbo-rails'

# Stimulus for JavaScript sprinkles
gem 'stimulus-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production (optional for SQLite version)
# gem 'redis', '~> 5.0'

# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# JWT for authentication
gem 'jwt'

# CORS handling
gem 'rack-cors'

# Email sending
gem 'mail'

# HTTP client
gem 'httparty'

# Geolocation
gem 'geoip'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

# TailwindCSS
gem 'tailwindcss-rails'

group :development, :test do
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'letter_opener'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
EOF

# Backup dos models originais
mkdir -p backup/models
cp app/models/*.rb backup/models/

# Criar config/database.yml
cat > config/database.yml << 'EOF'
# SQLite. Versions 3.8.0 and up are supported.
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this database to the same as development or production.
test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: db/production.sqlite3
EOF

# Remover configurações do Mongoid
rm -f config/mongoid.yml
rm -f config/initializers/mongoid.rb

# Atualizar application.rb
cat > config/application.rb << 'EOF'
require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApprovalWorkflow
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be referenced from inside your application with:
    #     Rails.application.config.some_setting = some_value

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Configure CORS
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options, :head]
      end
    end

    # Configure time zone
    config.time_zone = 'UTC'

    # Configure Active Job
    config.active_job.queue_adapter = :async

    # Configure logging
    config.log_level = :info
    config.logger = Logger.new(STDOUT)
    config.logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
    end
  end
end
EOF

echo "✅ Migração básica concluída!"
echo ""
echo "Próximos passos:"
echo "1. Execute: bundle install"
echo "2. Execute: rails generate model Approval"
echo "3. Execute: rails generate model ApprovalLog"
echo "4. Execute: rails generate model User"
echo "5. Edite as migrations geradas"
echo "6. Execute: rails db:migrate"
echo ""
echo "📖 Consulte README_SQLITE.md para instruções detalhadas"
