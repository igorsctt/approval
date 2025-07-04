# Authentication Controller

class AuthController < ApplicationController
  include Authorization
  layout 'auth'
  skip_before_action :authenticate_user!, only: [:login, :authenticate]
  
  def login
    # Redirecionar se já estiver logado
    redirect_to approvals_path if current_user
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
