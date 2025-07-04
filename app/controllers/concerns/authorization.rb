module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_current_user
  end

  private

  def authenticate_user!
    unless current_user
      if request.format.json?
        render json: { error: 'Authentication required' }, status: :unauthorized
      else
        redirect_to login_path, alert: 'Você precisa fazer login para acessar esta página.'
      end
    end
  end

  def require_admin!
    unless current_user&.admin?
      if request.format.json?
        render json: { error: 'Admin access required' }, status: :forbidden
      else
        redirect_to approvals_path, alert: 'Acesso negado. Apenas administradores podem realizar esta ação.'
      end
    end
  end

  def require_user_or_admin!
    unless current_user&.user? || current_user&.admin?
      if request.format.json?
        render json: { error: 'User access required' }, status: :forbidden
      else
        redirect_to login_path, alert: 'Acesso negado.'
      end
    end
  end

  def current_user
    return @current_user if defined?(@current_user)
    
    @current_user = find_user_from_session || find_user_from_token
  end

  def set_current_user
    # Make current_user available in views
    @current_user = current_user
  end

  def find_user_from_session
    return nil unless session[:user_id]
    
    User.find(session[:user_id]) if session[:user_id]
  rescue Mongoid::Errors::DocumentNotFound
    session[:user_id] = nil
    nil
  end

  def find_user_from_token
    token = extract_token_from_request
    return nil unless token

    User.find_by_token(token)
  end

  def extract_token_from_request
    # Try Authorization header
    auth_header = request.headers['Authorization']
    if auth_header&.start_with?('Bearer ')
      return auth_header.split(' ').last
    end

    # Try query parameter
    params[:token]
  end

  def login_user!(user)
    session[:user_id] = user.id.to_s
    user.update_login_stats!
  end

  def logout_user!
    session[:user_id] = nil
    @current_user = nil
  end

  def user_signed_in?
    current_user.present?
  end

  def admin_signed_in?
    current_user&.admin?
  end
end
