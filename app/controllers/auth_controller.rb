# Authentication Controller

class AuthController < ApplicationController
  include Authorization
  layout 'auth'
  skip_before_action :authenticate_user!, only: [:login, :authenticate, :debug_auth]
  
  def login
    # Redirecionar se já estiver logado
    redirect_to approvals_path if current_user
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
