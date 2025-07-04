# JWT Service for handling JSON Web Tokens

class JwtService
  SECRET_KEY = ENV['JWT_SECRET'] || 'your-secret-key-here'
  
  def self.encode(payload)
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end
  
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    decoded.first
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT decode error: #{e.message}"
    raise e
  end
  
  def self.valid_token?(token)
    decode(token)
    true
  rescue JWT::DecodeError
    false
  end
  
  def self.token_expired?(token)
    payload = decode(token)
    exp = payload['exp']
    return false unless exp
    
    Time.at(exp) < Time.current
  rescue JWT::DecodeError
    true
  end
  
  def self.extract_payload(token)
    decode(token)
  rescue JWT::DecodeError
    nil
  end
  
  def self.generate_approval_token(approval)
    payload = {
      approval_id: approval.id.to_s,
      email: approval.email,
      action_id: approval.action_id,
      exp: (approval.expire_at || 24.hours.from_now).to_i,
      iat: Time.current.to_i,
      type: 'approval'
    }
    
    encode(payload)
  end
  
  def self.validate_approval_token(token)
    payload = decode(token)
    
    # Check if token is for approval
    unless payload['type'] == 'approval'
      raise JWT::DecodeError, 'Invalid token type'
    end
    
    # Check if approval exists
    approval = Approval.find(payload['approval_id'])
    unless approval
      raise JWT::DecodeError, 'Approval not found'
    end
    
    # Check if approval can still be processed
    unless approval.can_be_processed?
      raise JWT::DecodeError, 'Approval cannot be processed'
    end
    
    { approval: approval, payload: payload }
  rescue Mongoid::Errors::DocumentNotFound
    raise JWT::DecodeError, 'Approval not found'
  end
end
