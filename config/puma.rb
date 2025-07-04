# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Configuration for development environment
if ENV.fetch("RAILS_ENV", "development") == "development"
  # Bind to all interfaces in development
  bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 3000 }}"
end

# Production configuration
if ENV.fetch("RAILS_ENV", "development") == "production"
  # Bind to Unix socket in production
  bind "unix://#{ENV.fetch("PUMA_SOCKET", "tmp/sockets/puma.sock")}"
  
  # Redirect output to log files
  stdout_redirect ENV.fetch("PUMA_STDOUT_LOG", "log/puma.stdout.log"), 
                  ENV.fetch("PUMA_STDERR_LOG", "log/puma.stderr.log"), 
                  true
  
  # Specify the PID file location
  pidfile ENV.fetch("PUMA_PIDFILE", "tmp/pids/puma.pid")
  
  # Change to match your CPU core count
  workers ENV.fetch("WEB_CONCURRENCY") { 4 }
  
  # Min and Max threads per worker
  threads 1, 6
  
  # Use the tag to identify the process
  tag "approval_workflow"
end

# MongoDB configuration for production
on_worker_boot do
  # Configuração específica para Mongoid em produção
  if defined?(Mongoid)
    Mongoid.load!(Rails.root.join('config', 'mongoid.yml'), Rails.env)
  end
end
