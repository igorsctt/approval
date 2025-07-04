#!/bin/bash
# Start script for Render.com that handles port conflicts

echo "Starting Rails application on Render..."

# Kill any existing puma processes (in case of restart issues)
pkill -f puma || true

# Wait a moment for processes to clean up
sleep 2

# Start Puma
exec bundle exec puma -C config/puma.rb
