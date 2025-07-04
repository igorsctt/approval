require 'mongoid'

class Approval
  include Mongoid::Document
  include Mongoid::Timestamps
  # Fields
  field :email, type: String
  field :requester_email, type: String
  field :approver_email, type: String
  field :description, type: String
  field :action_id, type: String
  field :login_config, type: Hash, default: {}
  field :callback_url, type: String
  field :details, type: Hash, default: {}
  field :status, type: String, default: 'created'
  field :signature, type: String
  field :expire_at, type: Time
  field :processed_at, type: Time
  field :ip_address, type: String
  field :user_agent, type: String
  field :location, type: String
  
  # Campos adicionais para o sistema web
  field :requested_by, type: String
  field :requested_by_email, type: String
  field :amount, type: Float
  field :category, type: String
  field :priority, type: String
  field :rejection_reason, type: String

  # Associations
  has_many :approval_logs, dependent: :destroy

  # Validations
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :requester_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :approver_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :requested_by_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :status, inclusion: { in: %w[created pending approved rejected expired] }
  validates :amount, numericality: { greater_than: 0 }, allow_blank: true
  validates :priority, inclusion: { in: %w[low medium high] }, allow_blank: true

  # Indexes
  index({ email: 1 }, { background: true })
  index({ action_id: 1 }, { background: true })
  index({ status: 1 }, { background: true })
  index({ created_at: 1 }, { background: true })
  index({ expire_at: 1 }, { background: true })
  index({ requested_by_email: 1 }, { background: true })
  index({ category: 1 }, { background: true })
  index({ priority: 1 }, { background: true })

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :expired, -> { where(status: 'expired') }
  scope :by_email, ->(email) { where(email: email) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_create :set_default_expiration
  before_create :generate_action_id
  before_save :normalize_email
  after_create :create_initial_log
  after_update :create_status_change_log, if: :status_changed?

  # Instance methods
  def pending?
    status == 'pending'
  end

  def approved?
    status == 'approved'
  end

  def rejected?
    status == 'rejected'
  end

  def expired?
    status == 'expired' || (expire_at && expire_at < Time.current)
  end

  def can_be_processed?
    %w[created pending].include?(status) && !expired?
  end

  def approve!(signature: nil, metadata: {})
    return false unless can_be_processed?
    
    update!(
      status: 'approved',
      signature: signature,
      processed_at: Time.current,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent],
      location: metadata[:location]
    )
  end

  def reject!(signature: nil, metadata: {})
    return false unless can_be_processed?
    
    update!(
      status: 'rejected',
      signature: signature,
      processed_at: Time.current,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent],
      location: metadata[:location]
    )
  end

  def mark_as_expired!
    update!(status: 'expired') if can_be_processed?
  end

  def generate_token
    payload = {
      approval_id: id.to_s,
      email: email,
      action_id: action_id,
      exp: (Time.current + 24.hours).to_i
    }
    JwtService.encode(payload)
  end

  def email_list
    email.split(',').map(&:strip).reject(&:blank?)
  end

  def time_remaining
    return 0 if expired?
    return nil unless expire_at
    
    [(expire_at - Time.current).to_i, 0].max
  end

  def self.cleanup_expired
    where(status: %w[created pending])
      .where(:expire_at.lte => Time.current)
      .update_all(status: 'expired')
  end

  private

  def set_default_expiration
    self.expire_at = Time.current + 7.days if expire_at.blank?
  end

  def generate_action_id
    return if action_id.present?
    
    # Gerar um ID baseado na categoria ou tipo de solicitação
    prefix = case category&.downcase
             when 'ti', 'tecnologia'
               'TI'
             when 'consultoria'
               'CONS'
             when 'software'
               'SOFT'
             when 'viagem'
               'VIAG'
             when 'materiais'
               'MAT'
             when 'treinamento'
               'TREI'
             when 'manutenção', 'manutencao'
               'MANUT'
             when 'segurança', 'seguranca'
               'SEG'
             when 'serviços', 'servicos'
               'SERV'
             when 'infraestrutura'
               'INFRA'
             else
               'SHELL'
             end
    
    # Gerar número sequencial baseado no count + timestamp
    timestamp = Time.current.strftime('%m%d')
    counter = sprintf('%02d', (Approval.count + 1) % 100)
    
    self.action_id = "#{prefix}-#{timestamp}-#{counter}"
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def create_initial_log
    log_data = {
      status: 'created',
      event: 'approval_created',
      ip_address: ip_address,
      user_agent: user_agent,
      location: location
    }
    log_data[:email] = email if email.present?
    
    approval_logs.create!(log_data)
  end

  def create_status_change_log
    log_data = {
      status: status,
      signature: signature,
      event: "approval_#{status}",
      ip_address: ip_address,
      user_agent: user_agent,
      location: location
    }
    log_data[:email] = email if email.present?
    
    approval_logs.create!(log_data)
  end
end
