#!/bin/bash
# Start script for Render.com that handles port conflicts

echo "Starting Rails application on Render..."

# Kill any existing puma processes more aggressively
pkill -f puma || true
pkill -f ruby || true
pkill -9 -f "puma.*10000" || true

# Wait longer for processes to clean up
echo "Waiting for port cleanup..."
sleep 5

# Check if port is still in use and try to free it
if lsof -ti:10000; then
    echo "Force killing processes on port 10000..."
    lsof -ti:10000 | xargs kill -9 || true
    sleep 3
fi

echo "Starting Puma..."
# Start Puma
exec bundle exec puma -C config/puma.rb
