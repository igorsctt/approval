class AuthorizationMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Skip authorization for certain paths
    if skip_authorization?(request.path)
      return @app.call(env)
    end

    # Check if user is authenticated
    user = current_user(request)
    unless user
      return unauthorized_response
    end

    # Check authorization based on path and method
    unless authorized?(user, request)
      return forbidden_response
    end

    # Set current user in environment for controllers
    env['current_user'] = user
    @app.call(env)
  end

  private

  def skip_authorization?(path)
    skip_paths = [
      '/login',
      '/health',
      '/assets',
      '/favicon.ico'
    ]
    
    skip_paths.any? { |skip_path| path.start_with?(skip_path) }
  end

  def current_user(request)
    token = extract_token(request)
    return nil unless token

    User.find_by_token(token)
  end

  def extract_token(request)
    # Try header first
    auth_header = request.get_header('HTTP_AUTHORIZATION')
    if auth_header&.start_with?('Bearer ')
      return auth_header.split(' ').last
    end

    # Try session
    session = request.session
    session['auth_token'] if session
  end

  def authorized?(user, request)
    path = request.path
    method = request.request_method.upcase

    # Admin can do everything
    return true if user.admin?

    # Regular users can only view/read
    case method
    when 'GET'
      # Users can view approvals and their details
      allowed_read_paths = [
        '/approvals',
        '/dashboard'
      ]
      
      # Allow viewing specific approval details
      if path.match?(/^\/approvals\/[\w-]+$/)
        return true
      end
      
      allowed_read_paths.any? { |allowed_path| path.start_with?(allowed_path) }
    when 'POST', 'PUT', 'PATCH', 'DELETE'
      # Only admins can create, update, or delete
      false
    else
      false
    end
  end

  def unauthorized_response
    [401, 
     { 'Content-Type' => 'application/json' }, 
     [{ error: 'Authentication required', message: 'Please login to access this resource' }.to_json]]
  end

  def forbidden_response
    [403, 
     { 'Content-Type' => 'application/json' }, 
     [{ error: 'Access forbidden', message: 'You do not have permission to perform this action' }.to_json]]
  end
end
