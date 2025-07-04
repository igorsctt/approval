# Mongoid configuration and initialization

# Load Mongoid configuration
require 'mongoid'

# Initialize Mongoid with the configuration file
Mongoid.load!(Rails.root.join('config', 'mongoid.yml'), Rails.env)

# Configure Mongoid logger
Mongoid.logger = Rails.logger
Mongo::Logger.logger = Rails.logger

# Set log level for MongoDB driver
Mongo::Logger.logger.level = Rails.env.production? ? Logger::INFO : Logger::DEBUG

# Configure connection pool settings
Mongoid.configure do |config|
  # Set default collection options
  config.belongs_to_required_by_default = false
  
  # Configure field options
  config.use_activesupport_time_zone = true
  config.use_utc = true
  
  # Configure preload models
  config.preload_models = Rails.env.production?
  
  # Configure raise_not_found_error
  config.raise_not_found_error = true
end

# Add custom validations and callbacks
module Mongoid
  module Document
    def self.included(base)
      base.extend(ClassMethods)
      super
    end
    
    module ClassMethods
      def generate_uuid
        SecureRandom.uuid
      end
    end
  end
end

# Add JSON serialization support
module Mongoid
  module Document
    def as_json(options = {})
      attrs = super(options)
      attrs['id'] = attrs.delete('_id').to_s if attrs['_id']
      attrs
    end
  end
end

# Handle MongoDB connection errors gracefully
module Mongoid
  module Clients
    class << self
      alias_method :original_default, :default
      
      def default
        original_default
      rescue Mongo::Error::NoServerAvailable => e
        Rails.logger.error "MongoDB connection failed: #{e.message}"
        raise e
      end
    end
  end
end

Rails.logger.info "Mongoid initialized successfully"
