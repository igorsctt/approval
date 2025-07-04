# Health Check Controller

class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def show
    health_status = {
      status: 'healthy',
      timestamp: Time.current.iso8601,
      version: Rails.application.class.module_parent_name,
      environment: Rails.env,
      services: check_services
    }
    
    if health_status[:services].all? { |_, status| status[:status] == 'healthy' }
      render json: health_status, status: :ok
    else
      render json: health_status, status: :service_unavailable
    end
  end

  private

  def check_services
    {
      database: check_database,
      email: check_email_service,
      jwt: check_jwt_service
    }
  end

  def check_database
    begin
      Mongoid::Clients.default.database.command(ping: 1)
      { status: 'healthy', message: 'Database connection successful' }
    rescue => e
      { status: 'unhealthy', message: "Database connection failed: #{e.message}" }
    end
  end

  def check_email_service
    begin
      # Simple check to see if email configuration is present
      if ENV['SMTP_HOST'].present? && ENV['SMTP_USERNAME'].present?
        { status: 'healthy', message: 'Email service configured' }
      else
        { status: 'unhealthy', message: 'Email service not configured' }
      end
    rescue => e
      { status: 'unhealthy', message: "Email service check failed: #{e.message}" }
    end
  end

  def check_jwt_service
    begin
      test_payload = { test: 'data', exp: (Time.current + 1.hour).to_i }
      token = JwtService.encode(test_payload)
      decoded = JwtService.decode(token)
      
      if decoded['test'] == 'data'
        { status: 'healthy', message: 'JWT service working' }
      else
        { status: 'unhealthy', message: 'JWT service verification failed' }
      end
    rescue => e
      { status: 'unhealthy', message: "JWT service check failed: #{e.message}" }
    end
  end
end
