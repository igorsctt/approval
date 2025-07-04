# Approval Log Serializer for API responses

class ApprovalLogSerializer < ActiveModel::Serializer
  attributes :id, :email, :status, :signature, :event, :ip_address,
             :user_agent, :location_info, :metadata, :timestamp

  def id
    object.id.to_s
  end

  def timestamp
    object.timestamp.iso8601
  end

  def location_info
    object.location_info
  end
end
