# Redis Cache Configuration

Rails.application.configure do
  # Configure Redis cache store
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
    reconnect_attempts: 3,
    reconnect_delay: 0.5,
    reconnect_delay_max: 30,
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.error "Redis error in #{method}: #{exception.message}"
      # Return the default value instead of raising
      returning
    }
  }
end

# Configure session store
Rails.application.config.session_store :cookie_store, key: '_approval_workflow_session'

# Add Redis health check
class RedisHealthCheck
  def self.healthy?
    Rails.cache.redis.ping == 'PONG'
  rescue => e
    Rails.logger.error "Redis health check failed: #{e.message}"
    false
  end
end

Rails.logger.info "Redis cache configuration loaded"
