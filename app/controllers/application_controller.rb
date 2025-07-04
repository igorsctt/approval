# Application Controller - Base controller for all controllers

class ApplicationController < ActionController::Base
  include Authorization
  
  protect_from_forgery with: :null_session
  
  # Make current_user available in views
  helper_method :current_user, :user_signed_in?, :admin_signed_in?
  
  # Skip authentication for public routes
  skip_before_action :authenticate_user!, only: [:health, :index]
  before_action :log_request
  
  rescue_from StandardError, with: :handle_standard_error
  rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found
  rescue_from Mongoid::Errors::Validations, with: :handle_validation_errors
  rescue_from JWT::DecodeError, with: :handle_jwt_error
  rescue_from JWT::ExpiredSignature, with: :handle_expired_token
  
  # For SPA support
  def index
    render file: 'public/index.html'
  end

  protected

  def extract_client_info
    {
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      location: GeolocationService.get_location_from_ip(request.remote_ip)
    }
  end

  private

  def log_request
    Rails.logger.info "#{request.method} #{request.path} - IP: #{request.remote_ip} - User-Agent: #{request.user_agent}"
  end

  def handle_standard_error(exception)
    Rails.logger.error "StandardError: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    if Rails.env.development?
      render json: { 
        error: exception.message,
        backtrace: exception.backtrace.first(10)
      }, status: :internal_server_error
    else
      render json: { error: 'Internal server error' }, status: :internal_server_error
    end
  end

  def handle_not_found(exception)
    Rails.logger.warn "Document not found: #{exception.message}"
    render json: { error: 'Resource not found' }, status: :not_found
  end

  def handle_validation_errors(exception)
    Rails.logger.warn "Validation error: #{exception.message}"
    render json: { 
      error: 'Validation failed',
      details: exception.document.errors.full_messages
    }, status: :unprocessable_entity
  end

  def handle_jwt_error(exception)
    Rails.logger.warn "JWT error: #{exception.message}"
    render json: { error: 'Invalid token' }, status: :unauthorized
  end

  def handle_expired_token(exception)
    Rails.logger.warn "Expired token: #{exception.message}"
    render json: { error: 'Token expired' }, status: :unauthorized
  end
end
