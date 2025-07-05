#!/bin/bash
# Build script for Render.com

set -o errexit

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p tmp/pids tmp/cache tmp/sockets log storage
chmod 755 tmp/pids tmp/cache tmp/sockets log storage

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

# Install Ruby dependencies
echo "Installing Ruby dependencies..."
bundle install

# Skip assets precompilation for now due to webpack/babel issues
# RAILS_ENV=production bundle exec rails assets:precompile
echo "Skipping assets:precompile due to webpack/babel compatibility issues"

# Create database if needed (MongoDB Atlas - already configured)
echo "Database configured via MongoDB Atlas"

# Run database seeds to create initial users
echo "Running database seeds..."
RAILS_ENV=production bundle exec rails db:seed

echo "Build completed successfully!"
