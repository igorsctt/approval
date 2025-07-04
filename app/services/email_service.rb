# Email Service for sending approval notification emails

class EmailService
  def self.send_approval_request(approval)
    return false unless approval.persisted?
    
    begin
      # Send email to each recipient
      approval.email_list.each do |email|
        ApprovalMailer.approval_request(approval, email).deliver_now
      end
      
      Rails.logger.info "Approval emails sent for approval #{approval.id}"
      true
    rescue => e
      Rails.logger.error "Failed to send approval emails for approval #{approval.id}: #{e.message}"
      false
    end
  end
  
  def self.send_approval_completed(approval)
    return false unless approval.persisted?
    
    begin
      # Send notification to callback URL if provided
      if approval.callback_url.present?
        send_webhook_notification(approval)
      end
      
      # Send email notification to the original requester
      if approval.details.dig('requester_email').present?
        ApprovalMailer.approval_completed(approval).deliver_now
      end
      
      Rails.logger.info "Approval completion notifications sent for approval #{approval.id}"
      true
    rescue => e
      Rails.logger.error "Failed to send approval completion notifications for approval #{approval.id}: #{e.message}"
      false
    end
  end
  
  def self.send_approval_expired(approval)
    return false unless approval.persisted?
    
    begin
      # Send expiration notification to callback URL if provided
      if approval.callback_url.present?
        send_webhook_notification(approval)
      end
      
      # Send email notification to the original requester
      if approval.details.dig('requester_email').present?
        ApprovalMailer.approval_expired(approval).deliver_now
      end
      
      Rails.logger.info "Approval expiration notifications sent for approval #{approval.id}"
      true
    rescue => e
      Rails.logger.error "Failed to send approval expiration notifications for approval #{approval.id}: #{e.message}"
      false
    end
  end
  
  def self.send_webhook_notification(approval)
    return false unless approval.callback_url.present?
    
    begin
      payload = {
        approval_id: approval.id.to_s,
        action_id: approval.action_id,
        status: approval.status,
        email: approval.email,
        signature: approval.signature,
        processed_at: approval.processed_at,
        details: approval.details
      }
      
      response = HTTParty.post(
        approval.callback_url,
        body: payload.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'User-Agent' => 'ApprovalWorkflow/1.0'
        },
        timeout: 10
      )
      
      if response.success?
        Rails.logger.info "Webhook notification sent successfully for approval #{approval.id}"
        true
      else
        Rails.logger.warn "Webhook notification failed for approval #{approval.id}: #{response.code} #{response.message}"
        false
      end
    rescue => e
      Rails.logger.error "Failed to send webhook notification for approval #{approval.id}: #{e.message}"
      false
    end
  end
  
  def self.test_email_configuration
    begin
      # Test email configuration by sending a test email
      test_email = ENV['SMTP_USERNAME']
      return false unless test_email
      
      ApprovalMailer.test_email(test_email).deliver_now
      Rails.logger.info "Test email sent successfully"
      true
    rescue => e
      Rails.logger.error "Email configuration test failed: #{e.message}"
      false
    end
  end
  
  def self.send_bulk_approval_reminders
    expired_approvals = Approval.where(
      status: 'pending',
      :expire_at.lte => 2.hours.from_now,
      :expire_at.gte => Time.current
    )
    
    sent_count = 0
    
    expired_approvals.each do |approval|
      if send_approval_reminder(approval)
        sent_count += 1
      end
    end
    
    Rails.logger.info "Sent #{sent_count} approval reminders"
    sent_count
  end
  
  def self.send_approval_reminder(approval)
    return false unless approval.pending?
    
    begin
      approval.email_list.each do |email|
        ApprovalMailer.approval_reminder(approval, email).deliver_now
      end
      
      Rails.logger.info "Approval reminder sent for approval #{approval.id}"
      true
    rescue => e
      Rails.logger.error "Failed to send approval reminder for approval #{approval.id}: #{e.message}"
      false
    end
  end
  
  private
  
  def self.format_email_content(approval)
    {
      approval_id: approval.id.to_s,
      description: approval.description,
      action_id: approval.action_id,
      created_at: approval.created_at.strftime('%Y-%m-%d %H:%M:%S UTC'),
      expire_at: approval.expire_at&.strftime('%Y-%m-%d %H:%M:%S UTC'),
      details: approval.details
    }
  end
end
