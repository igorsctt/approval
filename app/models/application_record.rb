# Application Record base class for Mongoid

class ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  
  # Global configurations
  store_in client: :default
  
  # Add common callbacks and methods here
  
  private
  
  def self.generate_uuid
    SecureRandom.uuid
  end
end
