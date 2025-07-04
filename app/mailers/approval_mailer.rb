# Approval Mailer for sending email notifications

class ApprovalMailer < ApplicationMailer
  default from: ENV.fetch('FROM_EMAIL', 'noreply@approvalworkflow.com')

  def approval_request(approval, recipient_email)
    @approval = approval
    @recipient_email = recipient_email
    @approval_url = generate_approval_url(approval)
    @expires_at = approval.expire_at
    @time_remaining = approval.time_remaining

    mail(
      to: recipient_email,
      subject: "Approval Request: #{approval.description}",
      template_name: 'approval_request'
    )
  end

  def approval_reminder(approval, recipient_email)
    @approval = approval
    @recipient_email = recipient_email
    @approval_url = generate_approval_url(approval)
    @expires_at = approval.expire_at
    @time_remaining = approval.time_remaining

    mail(
      to: recipient_email,
      subject: "Reminder: Approval Request - #{approval.description}",
      template_name: 'approval_reminder'
    )
  end

  def approval_completed(approval)
    @approval = approval
    @requester_email = approval.details.dig('requester_email') || approval.email
    @approved = approval.approved?
    @status_text = approval.approved? ? 'Approved' : 'Rejected'

    mail(
      to: @requester_email,
      subject: "Approval #{@status_text}: #{approval.description}",
      template_name: 'approval_completed'
    )
  end

  def approval_expired(approval)
    @approval = approval
    @requester_email = approval.details.dig('requester_email') || approval.email

    mail(
      to: @requester_email,
      subject: "Approval Expired: #{approval.description}",
      template_name: 'approval_expired'
    )
  end

  def test_email(recipient_email)
    @timestamp = Time.current
    @environment = Rails.env

    mail(
      to: recipient_email,
      subject: 'Approval Workflow - Email Configuration Test',
      template_name: 'test_email'
    )
  end

  private

  def generate_approval_url(approval)
    token = JwtService.generate_approval_token(approval)
    "#{ENV['APPROVAL_URL']}/approve?token=#{token}"
  end
end
