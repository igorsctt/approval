# Approval Workflow Rake Tasks

namespace :approval do
  desc 'Cleanup expired approvals'
  task cleanup_expired: :environment do
    puts "Starting cleanup of expired approvals..."
    
    result = ApprovalService.cleanup_expired_approvals
    
    if result[:success]
      puts "✓ #{result[:message]}"
    else
      puts "✗ Failed to cleanup expired approvals: #{result[:message]}"
      exit 1
    end
  end
  
  desc 'Send approval reminders'
  task send_reminders: :environment do
    puts "Sending approval reminders..."
    
    sent_count = EmailService.send_bulk_approval_reminders
    puts "✓ Sent #{sent_count} approval reminders"
  end
  
  desc 'Test email configuration'
  task test_email: :environment do
    puts "Testing email configuration..."
    
    if EmailService.test_email_configuration
      puts "✓ Email configuration test successful"
    else
      puts "✗ Email configuration test failed"
      exit 1
    end
  end
  
  desc 'Create sample approval request'
  task create_sample: :environment do
    puts "Creating sample approval request..."
    
    sample_params = {
      email: 'test@example.com',
      description: 'Sample approval request for testing',
      action_id: 'sample-test-001',
      callback_url: 'https://example.com/callback',
      expire_in_hours: 24,
      details: {
        amount: 1000,
        department: 'IT',
        requester: 'Test User'
      }
    }
    
    result = ApprovalService.create_approval(sample_params)
    
    if result[:success]
      puts "✓ Sample approval request created successfully"
      puts "   Approval ID: #{result[:data][:approval_id]}"
      puts "   Approval URL: #{result[:data][:approval_url]}"
    else
      puts "✗ Failed to create sample approval request: #{result[:message]}"
      exit 1
    end
  end
  
  desc 'Show approval statistics'
  task stats: :environment do
    puts "Approval Statistics:"
    puts "==================="
    
    total_approvals = Approval.count
    pending_approvals = Approval.pending.count
    approved_approvals = Approval.approved.count
    rejected_approvals = Approval.rejected.count
    expired_approvals = Approval.expired.count
    
    puts "Total Approvals: #{total_approvals}"
    puts "Pending: #{pending_approvals}"
    puts "Approved: #{approved_approvals}"
    puts "Rejected: #{rejected_approvals}"
    puts "Expired: #{expired_approvals}"
    
    if total_approvals > 0
      puts ""
      puts "Approval Rate: #{((approved_approvals.to_f / total_approvals) * 100).round(2)}%"
      puts "Rejection Rate: #{((rejected_approvals.to_f / total_approvals) * 100).round(2)}%"
    end
    
    puts ""
    puts "Recent Activity (last 7 days):"
    recent_approvals = Approval.where(:created_at.gte => 7.days.ago).count
    puts "New Approvals: #{recent_approvals}"
  end
  
  desc 'Check system health'
  task health_check: :environment do
    puts "Checking system health..."
    
    # Check database connection
    begin
      Mongoid::Clients.default.database.command(ping: 1)
      puts "✓ Database connection: OK"
    rescue => e
      puts "✗ Database connection: FAILED - #{e.message}"
      exit 1
    end
    
    # Check JWT service
    begin
      test_payload = { test: 'data', exp: (Time.current + 1.hour).to_i }
      token = JwtService.encode(test_payload)
      decoded = JwtService.decode(token)
      
      if decoded['test'] == 'data'
        puts "✓ JWT service: OK"
      else
        puts "✗ JWT service: FAILED - Token verification failed"
        exit 1
      end
    rescue => e
      puts "✗ JWT service: FAILED - #{e.message}"
      exit 1
    end
    
    # Check email configuration
    if ENV['SMTP_HOST'].present? && ENV['SMTP_USERNAME'].present?
      puts "✓ Email configuration: OK"
    else
      puts "✗ Email configuration: INCOMPLETE - Missing SMTP settings"
    end
    
    puts ""
    puts "System health check completed successfully!"
  end
end

# Daily maintenance task
namespace :maintenance do
  desc 'Run daily maintenance tasks'
  task daily: :environment do
    puts "Running daily maintenance tasks..."
    
    # Cleanup expired approvals
    Rake::Task['approval:cleanup_expired'].invoke
    
    # Send reminders
    Rake::Task['approval:send_reminders'].invoke
    
    puts "Daily maintenance completed!"
  end
end
