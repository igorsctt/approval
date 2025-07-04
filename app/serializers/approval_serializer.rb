# Approval Serializer for API responses

class ApprovalSerializer < ActiveModel::Serializer
  attributes :id, :email, :description, :action_id, :status, :signature,
             :details, :created_at, :updated_at, :expire_at, :processed_at,
             :time_remaining, :can_be_processed, :location_info

  def id
    object.id.to_s
  end

  def created_at
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end

  def expire_at
    object.expire_at&.iso8601
  end

  def processed_at
    object.processed_at&.iso8601
  end

  def time_remaining
    object.time_remaining
  end

  def can_be_processed
    object.can_be_processed?
  end

  def location_info
    return nil unless object.location.present?
    
    begin
      JSON.parse(object.location)
    rescue JSON::ParserError
      { city: object.location }
    end
  end
end
