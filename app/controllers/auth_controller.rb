# Authentication Controller

class AuthController < ApplicationController
  include Authorization
  layout 'auth'
  skip_before_action :authenticate_user!,
                     only: %i[login authenticate debug_auth debug_database production_debug create_admin_user check_env]

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
    email = params[:email]
    password = params[:password]

    Rails.logger.info "Debug auth attempt - Email: #{email}"

    # Test database connection
    Rails.logger.info 'Testing database connection...'
    Mongoid::Clients.default.database.command(ping: 1)
    Rails.logger.info 'Database connection OK'

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
  rescue StandardError => e
    Rails.logger.error "Debug auth error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: {
      error: e.message,
      backtrace: e.backtrace.first(5)
    }, status: 500
  end

  # Comprehensive debug method for database connection
  def debug_database
    Rails.logger.info '=== Database Debug Started ==='

    # Environment info
    env_info = {
      mongodb_uri: ENV['MONGODB_URI'],
      rails_env: ENV['RAILS_ENV'],
      database_name_from_uri: ENV['MONGODB_URI']&.split('/')&.last&.split('?')&.first
    }

    Rails.logger.info "Environment: #{env_info}"

    # Test database connection
    Rails.logger.info 'Testing database connection...'
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
      message: 'Database connection successful!'
    }
  rescue StandardError => e
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

  def authenticate
    Rails.logger.info '=== AUTHENTICATE START ==='
    Rails.logger.info "Request method: #{request.method}"
    Rails.logger.info "Request URL: #{request.url}"
    Rails.logger.info "User IP: #{request.remote_ip}"
    Rails.logger.info "User Agent: #{request.user_agent}"

    begin
      email = params[:email]
      password = params[:password]

      Rails.logger.info "Email param: #{email}"
      Rails.logger.info "Password present: #{password.present?}"

      # Test database connection first
      Rails.logger.info 'Testing database connection...'
      client = Mongoid::Clients.default
      client.database.command(ping: 1)
      Rails.logger.info 'Database ping successful'
      Rails.logger.info "Connected to database: #{client.database.name}"

      # Test user count
      user_count = User.count
      Rails.logger.info "Total users in database: #{user_count}"

      # Try to find user by email first
      Rails.logger.info "Searching for user with email: #{email}"
      found_user = User.find_by(email: email&.downcase&.strip)

      if found_user
        Rails.logger.info "User found - ID: #{found_user.id}, Email: #{found_user.email}, Active: #{found_user.active?}"
      else
        Rails.logger.warn "No user found with email: #{email}"
      end

      # Now try authentication
      Rails.logger.info 'Attempting authentication...'
      user = User.authenticate(email, password)

      if user
        Rails.logger.info "Authentication successful for user: #{user.email}"
        login_user!(user)
        Rails.logger.info 'User logged in successfully, redirecting to approvals'
        redirect_to approvals_path, notice: 'Login realizado com sucesso!'
      else
        Rails.logger.warn "Authentication failed for email: #{email}"
        redirect_to login_path, alert: 'Email ou senha inválidos'
      end
    rescue StandardError => e
      Rails.logger.error '=== AUTHENTICATE ERROR ==='
      Rails.logger.error "Error class: #{e.class}"
      Rails.logger.error "Error message: #{e.message}"
      Rails.logger.error 'Backtrace:'
      Rails.logger.error e.backtrace.join("\n")

      # Try to render a JSON error for AJAX requests, otherwise redirect
      if request.xhr? || request.content_type&.include?('application/json')
        render json: {
          error: 'Internal server error',
          message: e.message,
          details: e.backtrace.first(5)
        }, status: 500
      else
        redirect_to login_path, alert: 'Erro interno do servidor. Tente novamente.'
      end
    ensure
      Rails.logger.info '=== AUTHENTICATE END ==='
    end
  end

  def logout
    logout_user!
    redirect_to login_path, notice: 'Logout realizado com sucesso!'
  end

  # Special endpoint for production debugging
  def production_debug
    Rails.logger.info '=== PRODUCTION DEBUG START ==='

    begin
      # Environment information
      env_data = {
        rails_env: Rails.env,
        mongodb_uri_present: ENV['MONGODB_URI'].present?,
        mongodb_uri_preview: ENV['MONGODB_URI']&.gsub(/:[^:@]*@/, ':***@'),
        database_name_from_env: ENV['MONGODB_URI']&.split('/')&.last&.split('?')&.first
      }

      Rails.logger.info "Environment data: #{env_data}"

      # Test MongoDB connection
      Rails.logger.info 'Testing MongoDB connection...'
      client = Mongoid::Clients.default

      # Get MongoDB info
      ping_result = client.database.command(ping: 1)
      Rails.logger.info "MongoDB ping result: #{ping_result}"

      db_name = client.database.name
      Rails.logger.info "Connected to database: #{db_name}"

      # Get server info
      server_status = client.database.command(serverStatus: 1)
      Rails.logger.info "MongoDB host: #{server_status.dig('host')}"

      # Collection info
      collections = client.database.collection_names
      Rails.logger.info "Available collections: #{collections}"

      # User collection info
      if collections.include?('users')
        user_count = User.count
        Rails.logger.info "Users count: #{user_count}"

        sample_emails = User.limit(3).pluck(:email)
        Rails.logger.info "Sample user emails: #{sample_emails}"
      else
        Rails.logger.warn 'Users collection not found!'
      end

      render json: {
        success: true,
        environment: env_data,
        mongodb: {
          connected: true,
          database_name: db_name,
          collections: collections,
          host: server_status.dig('host'),
          users_count: collections.include?('users') ? User.count : 0
        },
        timestamp: Time.current
      }
    rescue StandardError => e
      Rails.logger.error '=== PRODUCTION DEBUG ERROR ==='
      Rails.logger.error "Error: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"

      render json: {
        success: false,
        error: e.message,
        error_class: e.class.name,
        backtrace: e.backtrace.first(10),
        environment: {
          rails_env: Rails.env,
          mongodb_uri_present: ENV['MONGODB_URI'].present?
        },
        timestamp: Time.current
      }, status: 500
    ensure
      Rails.logger.info '=== PRODUCTION DEBUG END ==='
    end
  end

  # Endpoint to create admin user in production
  def create_admin_user
    Rails.logger.info "=== CREATE ADMIN USER START ==="

    begin
      # Check if admin already exists
      existing_admin = User.find_by(email: 'admin@kaefer.com')

      if existing_admin
        Rails.logger.info "Admin user already exists"
        render json: {
          success: true,
          message: "Admin user already exists",
          user: { email: existing_admin.email, role: existing_admin.role }
        }
        return
      end

      # Create admin user
      admin_user = User.new(
        name: 'Administrator',
        email: 'admin@kaefer.com',
        role: 'admin',
        active: true
      )

      admin_user.password = 'admin123'

      if admin_user.save
        Rails.logger.info "Admin user created successfully"
        render json: {
          success: true,
          message: "Admin user created successfully",
          user: {
            id: admin_user.id.to_s,
            name: admin_user.name,
            email: admin_user.email,
            role: admin_user.role
          }
        }
      else
        Rails.logger.error "Failed to create admin user: #{admin_user.errors.full_messages}"
        render json: {
          success: false,
          error: "Failed to create admin user",
          errors: admin_user.errors.full_messages
        }, status: 422
      end

    rescue StandardError => e
      Rails.logger.error "Error creating admin user: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      render json: {
        success: false,
        error: e.message,
        error_class: e.class.name
      }, status: 500
    ensure
      Rails.logger.info "=== CREATE ADMIN USER END ==="
    end
  end
end
