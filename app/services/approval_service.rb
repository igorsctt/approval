# Approval Service - Main business logic for approval operations

class ApprovalService
  def self.create_approval(params, client_info = {})
    begin
      # Validate required parameters
      unless params[:email].present? && params[:description].present? && params[:action_id].present?
        return {
          success: false,
          message: 'Missing required parameters: email, description, action_id',
          status: :bad_request
        }
      end
      
      # Create approval record
      approval = Approval.new(
        email: params[:email],
        description: params[:description],
        action_id: params[:action_id],
        callback_url: params[:callback_url],
        login_config: params[:login_config] || {},
        details: params[:details] || {},
        status: 'pending',
        ip_address: client_info[:ip_address],
        user_agent: client_info[:user_agent],
        location: client_info[:location]&.to_json
      )
      
      # Set expiration if provided
      if params[:expire_in_hours].present?
        approval.expire_at = params[:expire_in_hours].to_i.hours.from_now
      end
      
      if approval.save
        # Generate approval token
        token = JwtService.generate_approval_token(approval)
        approval_url = "#{ENV['APPROVAL_URL']}/approve?token=#{token}"
        
        # Send approval email
        if EmailService.send_approval_request(approval)
          {
            success: true,
            data: {
              approval_id: approval.id.to_s,
              approval_url: approval_url,
              token: token,
              status: approval.status,
              expire_at: approval.expire_at
            },
            message: 'Approval request created successfully'
          }
        else
          # If email fails, still return success but with warning
          {
            success: true,
            data: {
              approval_id: approval.id.to_s,
              approval_url: approval_url,
              token: token,
              status: approval.status,
              expire_at: approval.expire_at
            },
            message: 'Approval request created successfully but email notification failed'
          }
        end
      else
        {
          success: false,
          message: 'Failed to create approval request',
          errors: approval.errors.full_messages,
          status: :unprocessable_entity
        }
      end
    rescue => e
      Rails.logger.error "Error creating approval: #{e.message}"
      {
        success: false,
        message: 'Internal server error',
        status: :internal_server_error
      }
    end
  end
  
  def self.validate_token(token)
    begin
      result = JwtService.validate_approval_token(token)
      approval = result[:approval]
      
      {
        success: true,
        data: {
          approval_id: approval.id.to_s,
          email: approval.email,
          description: approval.description,
          action_id: approval.action_id,
          status: approval.status,
          details: approval.details,
          expire_at: approval.expire_at,
          time_remaining: approval.time_remaining,
          can_be_processed: approval.can_be_processed?
        }
      }
    rescue JWT::DecodeError => e
      {
        success: false,
        message: e.message,
        status: :unauthorized
      }
    rescue => e
      Rails.logger.error "Error validating token: #{e.message}"
      {
        success: false,
        message: 'Token validation failed',
        status: :internal_server_error
      }
    end
  end
  
  def self.approve_request(token, signature, client_info = {})
    begin
      result = JwtService.validate_approval_token(token)
      approval = result[:approval]
      
      # Update approval status
      metadata = {
        ip_address: client_info[:ip_address],
        user_agent: client_info[:user_agent],
        location: client_info[:location]&.to_json
      }
      
      if approval.approve!(signature: signature, metadata: metadata)
        # Send completion notification
        EmailService.send_approval_completed(approval)
        
        {
          success: true,
          data: {
            approval_id: approval.id.to_s,
            status: approval.status,
            signature: approval.signature,
            processed_at: approval.processed_at
          },
          message: 'Approval request approved successfully'
        }
      else
        {
          success: false,
          message: 'Failed to approve request',
          status: :unprocessable_entity
        }
      end
    rescue JWT::DecodeError => e
      {
        success: false,
        message: e.message,
        status: :unauthorized
      }
    rescue => e
      Rails.logger.error "Error approving request: #{e.message}"
      {
        success: false,
        message: 'Internal server error',
        status: :internal_server_error
      }
    end
  end
  
  def self.reject_request(token, signature, reason, client_info = {})
    begin
      result = JwtService.validate_approval_token(token)
      approval = result[:approval]
      
      # Update approval status
      metadata = {
        ip_address: client_info[:ip_address],
        user_agent: client_info[:user_agent],
        location: client_info[:location]&.to_json,
        reason: reason
      }
      
      if approval.reject!(signature: signature, metadata: metadata)
        # Send completion notification
        EmailService.send_approval_completed(approval)
        
        {
          success: true,
          data: {
            approval_id: approval.id.to_s,
            status: approval.status,
            signature: approval.signature,
            processed_at: approval.processed_at,
            reason: reason
          },
          message: 'Approval request rejected successfully'
        }
      else
        {
          success: false,
          message: 'Failed to reject request',
          status: :unprocessable_entity
        }
      end
    rescue JWT::DecodeError => e
      {
        success: false,
        message: e.message,
        status: :unauthorized
      }
    rescue => e
      Rails.logger.error "Error rejecting request: #{e.message}"
      {
        success: false,
        message: 'Internal server error',
        status: :internal_server_error
      }
    end
  end
  
  def self.list_approvals(email, page = 1, per_page = 10)
    begin
      approvals = Approval.by_email(email)
                         .recent
                         .page(page)
                         .per(per_page)
      
      {
        success: true,
        data: approvals.map { |approval| format_approval_data(approval) },
        meta: {
          total: approvals.total_count,
          page: approvals.current_page,
          per_page: approvals.limit_value,
          total_pages: approvals.total_pages
        }
      }
    rescue => e
      Rails.logger.error "Error listing approvals: #{e.message}"
      {
        success: false,
        message: 'Internal server error',
        status: :internal_server_error
      }
    end
  end
  
  def self.get_approval_logs(approval_id)
    begin
      approval = Approval.find(approval_id)
      logs = approval.approval_logs.recent
      
      {
        success: true,
        data: logs.map { |log| format_log_data(log) }
      }
    rescue Mongoid::Errors::DocumentNotFound
      {
        success: false,
        message: 'Approval not found',
        status: :not_found
      }
    rescue => e
      Rails.logger.error "Error getting approval logs: #{e.message}"
      {
        success: false,
        message: 'Internal server error',
        status: :internal_server_error
      }
    end
  end
  
  def self.cleanup_expired_approvals
    begin
      expired_count = Approval.cleanup_expired
      Rails.logger.info "Marked #{expired_count} approvals as expired"
      
      # Send expiration notifications
      expired_approvals = Approval.expired.where(
        :updated_at.gte => 1.hour.ago
      )
      
      expired_approvals.each do |approval|
        EmailService.send_approval_expired(approval)
      end
      
      {
        success: true,
        data: { expired_count: expired_count },
        message: "Cleaned up #{expired_count} expired approvals"
      }
    rescue => e
      Rails.logger.error "Error cleaning up expired approvals: #{e.message}"
      {
        success: false,
        message: 'Internal server error',
        status: :internal_server_error
      }
    end
  end
  
  private
  
  def self.format_approval_data(approval)
    {
      id: approval.id.to_s,
      email: approval.email,
      description: approval.description,
      action_id: approval.action_id,
      status: approval.status,
      signature: approval.signature,
      details: approval.details,
      created_at: approval.created_at.iso8601,
      updated_at: approval.updated_at.iso8601,
      expire_at: approval.expire_at&.iso8601,
      processed_at: approval.processed_at&.iso8601,
      time_remaining: approval.time_remaining,
      can_be_processed: approval.can_be_processed?
    }
  end
  
  def self.format_log_data(log)
    {
      id: log.id.to_s,
      event: log.event,
      status: log.status,
      email: log.email,
      signature: log.signature,
      ip_address: log.ip_address,
      user_agent: log.user_agent,
      location: log.location_info,
      metadata: log.metadata,
      timestamp: log.timestamp.iso8601
    }
  end
end
