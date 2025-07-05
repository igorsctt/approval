#!/bin/bash
# Alternative start script - true single process mode

echo "Starting Rails in true single process mode..."

# Ensure all necessary directories exist
echo "Creating necessary directories..."
mkdir -p tmp/pids
mkdir -p tmp/cache
mkdir -p tmp/sockets
mkdir -p log
mkdir -p storage

# Kill any existing processes
pkill -f puma || true
sleep 3

# Start Puma in true single mode (workers = 0, no clustering)
exec bundle exec puma -t 1:3 -p ${PORT:-10000} -w 0 --env production
