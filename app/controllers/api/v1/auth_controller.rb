# API V1 Authentication Controller

class Api::V1::AuthController < Api::BaseController
  before_action :authenticate_user!, except: [:login, :validate]
  
  # POST /api/v1/auth/login
  def login
    email = params[:email]
    password = params[:password]
    
    if email.blank? || password.blank?
      return error_response('Email and password are required', :bad_request)
    end
    
    user = User.authenticate(email, password)
    
    if user
      token = user.generate_jwt_token
      success_response({
        token: token,
        user: {
          id: user.id.to_s,
          email: user.email,
          name: user.name,
          role: user.role
        }
      }, 'Login successful')
    else
      error_response('Invalid email or password', :unauthorized)
    end
  end
  
  # POST /api/v1/auth/validate
  def validate
    token = params[:token] || extract_token_from_header
    
    if token.blank?
      return error_response('Token is required', :bad_request)
    end
    
    user = User.find_by_token(token)
    
    if user
      success_response({
        valid: true,
        user: {
          id: user.id.to_s,
          email: user.email,
          name: user.name,
          role: user.role
        }
      }, 'Token is valid')
    else
      error_response('Invalid or expired token', :unauthorized)
    end
  end
  
  private
  
  def extract_token_from_header
    header = request.headers['Authorization']
    header&.split(' ')&.last
  end
end
