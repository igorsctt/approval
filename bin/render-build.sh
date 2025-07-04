#!/bin/bash
# Build script for Render.com

set -o errexit

# Install dependencies
bundle install

# Precompile assets
RAILS_ENV=production bundle exec rails assets:precompile

# Create database if needed (MongoDB Atlas - already configured)
echo "Database configured via MongoDB Atlas"
