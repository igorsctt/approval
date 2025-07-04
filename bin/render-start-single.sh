#!/bin/bash
# Alternative start script - single process mode

echo "Starting Rails in single process mode..."

# Kill any existing processes
pkill -f puma || true
sleep 3

# Start Puma in single mode (no clustering)
exec bundle exec puma -t 1:3 -p ${PORT:-10000} --env production
