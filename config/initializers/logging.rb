# Custom logging configuration

# Configure Rails logger
Rails.application.configure do
  # Custom log formatter
  config.log_formatter = proc do |severity, datetime, progname, msg|
    formatted_datetime = datetime.strftime('%Y-%m-%d %H:%M:%S.%3N')
    "[#{formatted_datetime}] #{severity.ljust(5)} #{progname}: #{msg}\n"
  end

  # Add request ID to logs
  config.log_tags = [
    :request_id,
    -> (request) { "IP:#{request.remote_ip}" },
    -> (request) { "User:#{request.headers['X-User-Email'] || 'anonymous'}" }
  ]
end

# Custom logger for approval operations
class ApprovalLogger
  def self.log_approval_created(approval, client_info = {})
    Rails.logger.info "APPROVAL_CREATED: #{approval.id} | Email: #{approval.email} | Action: #{approval.action_id} | IP: #{client_info[:ip_address]}"
  end

  def self.log_approval_processed(approval, action, client_info = {})
    Rails.logger.info "APPROVAL_#{action.upcase}: #{approval.id} | Email: #{approval.email} | Action: #{approval.action_id} | Signature: #{approval.signature} | IP: #{client_info[:ip_address]}"
  end

  def self.log_approval_expired(approval)
    Rails.logger.info "APPROVAL_EXPIRED: #{approval.id} | Email: #{approval.email} | Action: #{approval.action_id}"
  end

  def self.log_email_sent(approval, recipient, email_type)
    Rails.logger.info "EMAIL_SENT: #{email_type} | Approval: #{approval.id} | Recipient: #{recipient}"
  end

  def self.log_email_failed(approval, recipient, email_type, error)
    Rails.logger.error "EMAIL_FAILED: #{email_type} | Approval: #{approval.id} | Recipient: #{recipient} | Error: #{error.message}"
  end

  def self.log_webhook_sent(approval, url, status)
    Rails.logger.info "WEBHOOK_SENT: Approval: #{approval.id} | URL: #{url} | Status: #{status}"
  end

  def self.log_webhook_failed(approval, url, error)
    Rails.logger.error "WEBHOOK_FAILED: Approval: #{approval.id} | URL: #{url} | Error: #{error.message}"
  end

  def self.log_api_request(endpoint, params, client_info = {})
    Rails.logger.info "API_REQUEST: #{endpoint} | Params: #{params.inspect} | IP: #{client_info[:ip_address]}"
  end

  def self.log_security_event(event_type, details, client_info = {})
    Rails.logger.warn "SECURITY_EVENT: #{event_type} | Details: #{details} | IP: #{client_info[:ip_address]} | User-Agent: #{client_info[:user_agent]}"
  end
end

# Log rotation configuration
if Rails.env.production?
  require 'logger'
  
  # Set up log rotation
  logger = Logger.new(
    Rails.root.join('log', 'production.log'),
    'daily'
  )
  
  Rails.logger = ActiveSupport::TaggedLogging.new(logger)
end

# Performance monitoring
class PerformanceLogger
  def self.log_slow_query(query, duration)
    if duration > 1.0  # Log queries slower than 1 second
      Rails.logger.warn "SLOW_QUERY: #{query} | Duration: #{duration.round(3)}s"
    end
  end

  def self.log_memory_usage
    memory_usage = `ps -o rss= -p #{Process.pid}`.strip.to_i / 1024
    Rails.logger.info "MEMORY_USAGE: #{memory_usage}MB"
  end
end

# Initialize structured logging
Rails.logger.info "Logging configuration initialized"
Rails.logger.info "Log level: #{Rails.logger.level}"
Rails.logger.info "Environment: #{Rails.env}"
