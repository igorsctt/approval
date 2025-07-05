source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.2.0'

# Use MongoDB as the database for Active Record
gem 'mongoid', '~> 8.1'

# NullDB adapter to prevent ActiveRecord database errors
gem 'activerecord-nulldb-adapter'

# Use Puma as the app server
gem 'puma', '~> 6.0'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# JavaScript runtime (removed mini_racer due to native compilation issues)

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 5.0'  # Temporarily disabled due to build issues

# Turbo for fast page navigation
gem 'turbo-rails'

# Stimulus for JavaScript sprinkles
gem 'stimulus-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'

# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# JWT for authentication
gem 'jwt'

# YAML processing
gem 'safe_yaml'

# CORS handling
gem 'rack-cors'

# Email sending
gem 'mail'

# HTTP client
gem 'httparty'

# Geolocation
gem 'geoip'

# Environment variables
gem 'dotenv-rails'  # Para carregar variáveis do .env

# Pagination
gem 'kaminari'

# Validation
# gem 'dry-validation'  # Temporariamente removido

# Serializers
gem 'active_model_serializers'

# TailwindCSS
gem 'tailwindcss-rails'

# Image processing
gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner-mongoid'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be commented out to disable the feature.
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Production optimizations
group :production do
  # Better logging for production
  gem 'lograge'
  # JavaScript runtime removed (mini_racer) due to build issues on free hosting
end

gem 'sinatra', '~> 4.1'
