#!/bin/bash
# Start script for Render.com without PID file (fallback option)

echo "Starting Rails application on Render (no PID mode)..."

# Ensure all necessary directories exist
echo "Creating necessary directories..."
mkdir -p tmp/pids
mkdir -p tmp/cache
mkdir -p tmp/sockets
mkdir -p log
mkdir -p storage

# Kill any existing processes
pkill -f puma || true
pkill -f ruby || true
sleep 3

echo "Starting Puma without PID file..."
# Start Puma without PID file
exec bundle exec puma -t 1:3 -p ${PORT:-10000} -w 0 --env production --no-pidfile
