require 'mongoid'

class ApprovalLog
  include Mongoid::Document
  include Mongoid::Timestamps
  # Fields
  field :email, type: String
  field :status, type: String
  field :signature, type: String
  field :ip_address, type: String
  field :user_agent, type: String
  field :location, type: String
  field :event, type: String
  field :metadata, type: Hash, default: {}
  field :timestamp, type: Time, default: -> { Time.current }

  # Associations
  belongs_to :approval

  # Validations
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :status, presence: true
  validates :event, presence: true
  validates :timestamp, presence: true

  # Indexes
  index({ approval_id: 1 }, { background: true })
  index({ email: 1 }, { background: true })
  index({ status: 1 }, { background: true })
  index({ event: 1 }, { background: true })
  index({ timestamp: 1 }, { background: true })
  index({ ip_address: 1 }, { background: true })

  # Scopes
  scope :by_approval, ->(approval_id) { where(approval_id: approval_id) }
  scope :by_email, ->(email) { where(email: email) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_event, ->(event) { where(event: event) }
  scope :recent, -> { order(timestamp: :desc) }
  scope :in_date_range, ->(start_date, end_date) { where(timestamp: start_date..end_date) }

  # Callbacks
  before_create :set_timestamp
  before_create :extract_location_from_ip

  # Instance methods
  def approval_action?
    %w[approval_approved approval_rejected].include?(event)
  end

  def creation_log?
    event == 'approval_created'
  end

  def status_change_log?
    %w[approval_approved approval_rejected approval_expired].include?(event)
  end

  def location_info
    return {} unless location.present?
    
    begin
      JSON.parse(location)
    rescue JSON::ParserError
      { city: location }
    end
  end

  def formatted_timestamp
    timestamp.strftime('%Y-%m-%d %H:%M:%S UTC')
  end

  def user_info
    {
      email: email,
      ip_address: ip_address,
      user_agent: user_agent,
      location: location_info,
      timestamp: formatted_timestamp
    }
  end

  # Class methods
  def self.create_for_approval(approval, event, metadata = {})
    create!(
      approval: approval,
      email: approval.email,
      status: approval.status,
      signature: approval.signature,
      event: event,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent],
      location: metadata[:location],
      metadata: metadata.except(:ip_address, :user_agent, :location)
    )
  end

  def self.audit_trail_for_approval(approval_id)
    by_approval(approval_id).recent.map do |log|
      {
        id: log.id.to_s,
        event: log.event,
        status: log.status,
        email: log.email,
        signature: log.signature,
        timestamp: log.formatted_timestamp,
        ip_address: log.ip_address,
        user_agent: log.user_agent,
        location: log.location_info,
        metadata: log.metadata
      }
    end
  end

  def self.summary_by_status
    pipeline = [
      { "$group" => { "_id" => "$status", "count" => { "$sum" => 1 } } },
      { "$sort" => { "count" => -1 } }
    ]
    
    collection.aggregate(pipeline).to_a
  end

  def self.activity_by_date(days = 30)
    start_date = days.days.ago.beginning_of_day
    end_date = Time.current.end_of_day
    
    pipeline = [
      { "$match" => { "timestamp" => { "$gte" => start_date, "$lte" => end_date } } },
      { "$group" => { 
          "_id" => { "$dateToString" => { "format" => "%Y-%m-%d", "date" => "$timestamp" } },
          "count" => { "$sum" => 1 }
        }
      },
      { "$sort" => { "_id" => 1 } }
    ]
    
    collection.aggregate(pipeline).to_a
  end

  private

  def set_timestamp
    self.timestamp = Time.current
  end

  def extract_location_from_ip
    return unless ip_address.present?
    
    begin
      location_data = GeolocationService.get_location_from_ip(ip_address)
      self.location = location_data.to_json if location_data
    rescue => e
      Rails.logger.warn "Failed to extract location from IP #{ip_address}: #{e.message}"
    end
  end
end
