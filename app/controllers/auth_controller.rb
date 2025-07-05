# Authentication Controller

class AuthController < ApplicationController
  include Authorization
  layout 'auth'
  skip_before_action :authenticate_user!, only: [:login, :authenticate, :debug_auth, :debug_database, :check_env]
  
  def login
    # Redirecionar se já estiver logado
    redirect_to approvals_path if current_user
  end
  
  # Método para verificar variáveis de ambiente
  def check_env
    render json: {
      mongodb_uri: ENV['MONGODB_URI'],
      rails_env: ENV['RAILS_ENV'],
      database_name: ENV['MONGODB_URI']&.split('/')&.last&.split('?')&.first
    }
  end
  
  # Método debug temporário para ver erros reais
  def debug_auth
    begin
      email = params[:email]
      password = params[:password]
      
      Rails.logger.info "Debug auth attempt - Email: #{email}"
      
      # Test database connection
      Rails.logger.info "Testing database connection..."
      Mongoid::Clients.default.database.command(ping: 1)
      Rails.logger.info "Database connection OK"
      
      # Test user count
      user_count = User.count
      Rails.logger.info "User count: #{user_count}"
      
      # Buscar usuário por email e validar senha
      user = User.authenticate(email, password)
      
      if user
        render json: { 
          success: true, 
          user: { id: user.id, email: user.email, role: user.role }
        }
      else
        render json: { 
          success: false, 
          message: 'Email ou senha inválidos',
          user_count: user_count
        }
      end
    rescue => e
      Rails.logger.error "Debug auth error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { 
        error: e.message,
        backtrace: e.backtrace.first(5)
      }, status: 500
    end
  end
  
  # Comprehensive debug method for database connection
  def debug_database
    begin
      Rails.logger.info "=== Database Debug Started ==="
      
      # Environment info
      env_info = {
        mongodb_uri: ENV['MONGODB_URI'],
        rails_env: ENV['RAILS_ENV'],
        database_name_from_uri: ENV['MONGODB_URI']&.split('/')&.last&.split('?')&.first
      }
      
      Rails.logger.info "Environment: #{env_info}"
      
      # Test database connection
      Rails.logger.info "Testing database connection..."
      client = Mongoid::Clients.default
      client.database.command(ping: 1)
      
      # Get actual database name
      actual_db_name = client.database.name
      Rails.logger.info "Connected to database: #{actual_db_name}"
      
      # Get collection names
      collections = client.database.collection_names
      Rails.logger.info "Collections: #{collections}"
      
      # Test User model
      user_count = User.count
      Rails.logger.info "User count: #{user_count}"
      
      # Sample user data (if any)
      sample_users = User.limit(3).pluck(:email)
      Rails.logger.info "Sample users: #{sample_users}"
      
      render json: {
        success: true,
        environment: env_info,
        database: {
          name: actual_db_name,
          collections: collections,
          user_count: user_count,
          sample_users: sample_users
        },
        message: "Database connection successful!"
      }
      
    rescue => e
      Rails.logger.error "Database debug error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        success: false,
        error: e.message,
        environment: {
          mongodb_uri: ENV['MONGODB_URI'],
          rails_env: ENV['RAILS_ENV'],
          database_name_from_uri: ENV['MONGODB_URI']&.split('/')&.last&.split('?')&.first
        },
        backtrace: e.backtrace.first(5)
      }, status: 500
    end
  end
  
  def authenticate
    email = params[:email]
    password = params[:password]
    
    # Buscar usuário por email e validar senha
    user = User.authenticate(email, password)
    
    if user
      login_user!(user)
      redirect_to approvals_path, notice: 'Login realizado com sucesso!'
    else
      redirect_to login_path, alert: 'Email ou senha inválidos'
    end
  end
  
  def logout
    logout_user!
    redirect_to login_path, notice: 'Logout realizado com sucesso!'
  end
end
