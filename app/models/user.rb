require 'mongoid'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Fields
  field :email, type: String
  field :name, type: String
  field :password_digest, type: String
  field :role, type: String, default: 'user'
  field :active, type: Boolean, default: true
  field :last_login_at, type: Time
  field :login_count, type: Integer, default: 0

  # Authentication method (replacing has_secure_password)
  require 'bcrypt'
  
  def password=(new_password)
    self.password_digest = BCrypt::Password.create(new_password)
  end
  
  def authenticate_password(password)
    BCrypt::Password.new(password_digest) == password
  end

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :role, inclusion: { in: %w[user admin] }

  # Indexes
  index({ email: 1 }, { unique: true, background: true })
  index({ role: 1 }, { background: true })
  index({ active: 1 }, { background: true })

  # Scopes
  scope :active, -> { where(active: true) }
  scope :admins, -> { where(role: 'admin') }
  scope :users, -> { where(role: 'user') }
  scope :recent_logins, -> { where(:last_login_at.gte => 30.days.ago) }

  # Callbacks
  before_save :normalize_email
  before_create :set_default_role

  # Instance methods
  def admin?
    role == 'admin'
  end

  def user?
    role == 'user'
  end

  def active?
    active
  end

  def full_name
    name
  end

  def display_name
    name.presence || email
  end

  def update_login_stats!
    inc(login_count: 1)
    update!(last_login_at: Time.current)
  end

  def generate_jwt_token
    payload = {
      user_id: id.to_s,
      email: email,
      role: role,
      exp: (Time.current + 24.hours).to_i
    }
    JwtService.encode(payload)
  end

  def recent_login?
    last_login_at && last_login_at > 7.days.ago
  end

  # Class methods
  def self.authenticate(email, password)
    user = find_by(email: email.downcase.strip)
    return nil unless user&.active?
    
    if user.authenticate_password(password)
      user.update_login_stats!
      user
    else
      nil
    end
  end

  def self.find_by_token(token)
    begin
      payload = JwtService.decode(token)
      user = find(payload['user_id'])
      user if user&.active?
    rescue JWT::DecodeError, Mongoid::Errors::DocumentNotFound
      nil
    end
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def set_default_role
    self.role ||= 'user'
  end
end
