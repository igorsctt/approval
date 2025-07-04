# Models para versão SQLite (ActiveRecord)
# Copie estes modelos após executar ./migrate_to_sqlite.sh

# app/models/approval.rb (SQLite version)
class Approval < ApplicationRecord
  has_many :approval_logs, dependent: :destroy
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :action_id, presence: true
  validates :callback_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :status, inclusion: { in: %w[created pending approved rejected expired] }
  
  enum status: { created: 0, pending: 1, approved: 2, rejected: 3, expired: 4 }
  
  scope :pending, -> { where(status: 'pending') }
  scope :expired, -> { where('expire_at < ?', Time.current) }
  scope :by_email, ->(email) { where(email: email) }
  
  before_create :set_default_status
  before_save :set_processed_at
  
  def expired?
    expire_at.present? && expire_at < Time.current
  end
  
  def pending?
    status == 'pending'
  end
  
  def completed?
    %w[approved rejected].include?(status)
  end
  
  def approve!(ip_address: nil, user_agent: nil, location: nil)
    transaction do
      update!(status: 'approved', processed_at: Time.current)
      approval_logs.create!(
        action: 'approved',
        ip_address: ip_address,
        user_agent: user_agent,
        location: location
      )
    end
  end
  
  def reject!(ip_address: nil, user_agent: nil, location: nil, reason: nil)
    transaction do
      update!(status: 'rejected', processed_at: Time.current)
      approval_logs.create!(
        action: 'rejected',
        ip_address: ip_address,
        user_agent: user_agent,
        location: location,
        details: reason
      )
    end
  end
  
  def expire!
    transaction do
      update!(status: 'expired', processed_at: Time.current)
      approval_logs.create!(
        action: 'expired',
        ip_address: 'system',
        user_agent: 'system',
        location: 'system'
      )
    end
  end
  
  def log_view(ip_address: nil, user_agent: nil, location: nil)
    approval_logs.create!(
      action: 'viewed',
      ip_address: ip_address,
      user_agent: user_agent,
      location: location
    )
  end
  
  def log_action(action, ip_address: nil, user_agent: nil, location: nil, details: nil)
    approval_logs.create!(
      action: action,
      ip_address: ip_address,
      user_agent: user_agent,
      location: location,
      details: details
    )
  end
  
  def self.cleanup_expired
    expired.find_each do |approval|
      approval.expire!
    end
  end
  
  private
  
  def set_default_status
    self.status ||= 'created'
  end
  
  def set_processed_at
    if status_changed? && completed?
      self.processed_at = Time.current
    end
  end
end

# app/models/approval_log.rb (SQLite version)
class ApprovalLog < ApplicationRecord
  belongs_to :approval
  
  validates :action, presence: true
  validates :ip_address, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  
  def self.actions
    %w[created viewed approved rejected expired reminded]
  end
end

# app/models/user.rb (SQLite version)
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, inclusion: { in: %w[admin user] }
  
  enum role: { user: 0, admin: 1 }
  
  scope :admins, -> { where(role: 'admin') }
  scope :users, -> { where(role: 'user') }
  
  def admin?
    role == 'admin'
  end
  
  def can_approve?
    admin?
  end
end
