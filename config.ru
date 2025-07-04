# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Enable rack-attack for rate limiting (optional)
# require 'rack/attack'
# use Rack::Attack

# Enable request logging
use Rack::CommonLogger

# Enable static file serving in production
use Rack::Static, urls: ["/assets"], root: "public"

run Rails.application

Rails.logger.info "Application started successfully"
