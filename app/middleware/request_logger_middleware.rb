class RequestLoggerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Log all authentication-related requests
    if request.path.include?('auth') || request.path.include?('login')
      Rails.logger.info "=== REQUEST LOG ==="
      Rails.logger.info "Method: #{request.request_method}"
      Rails.logger.info "Path: #{request.path}"
      Rails.logger.info "Query: #{request.query_string}"
      Rails.logger.info "Content-Type: #{request.content_type}"
      Rails.logger.info "User-Agent: #{request.user_agent}"
      Rails.logger.info "IP: #{request.ip}"
      
      # Log POST parameters (be careful with passwords)
      if request.post? && request.params.any?
        safe_params = request.params.dup
        safe_params['password'] = '[FILTERED]' if safe_params['password']
        Rails.logger.info "POST params: #{safe_params}"
      end
      
      Rails.logger.info "=== REQUEST LOG END ==="
    end
    
    status, headers, response = @app.call(env)
    
    # Log response for auth requests
    if request.path.include?('auth') || request.path.include?('login')
      Rails.logger.info "=== RESPONSE LOG ==="
      Rails.logger.info "Status: #{status}"
      Rails.logger.info "Location header: #{headers['Location']}" if headers['Location']
      Rails.logger.info "=== RESPONSE LOG END ==="
    end
    
    [status, headers, response]
  end
end
