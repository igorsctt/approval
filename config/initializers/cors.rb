# CORS configuration for API endpoints

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3000,http://localhost:3001').split(',')
    
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      max_age: 86400
      
    resource '/health',
      headers: :any,
      methods: [:get, :options],
      credentials: false
  end
  
  # Allow all origins in development
  if Rails.env.development?
    allow do
      origins '*'
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end
end

Rails.logger.info "CORS configuration loaded"
