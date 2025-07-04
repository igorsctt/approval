# Seeds file for initial data

# Create admin user if it doesn't exist
admin_user = User.find_or_create_by(email: 'admin@kaefer.com') do |user|
  user.name = 'KAEFER Administrator'
  user.password = 'admin123'
  user.role = 'admin'
  user.active = true
end

if admin_user.persisted?
  puts "✓ Admin user created/found: #{admin_user.email}"
else
  puts "✗ Failed to create admin user: #{admin_user.errors.full_messages.join(', ')}"
end

# Create sample regular user
sample_user = User.find_or_create_by(email: 'user@kaefer.com') do |user|
  user.name = 'KAEFER User'
  user.password = 'user123'
  user.role = 'user'
  user.active = true
end

if sample_user.persisted?
  puts "✓ Sample user created/found: #{sample_user.email}"
else
  puts "✗ Failed to create sample user: #{sample_user.errors.full_messages.join(', ')}"
end

# Create sample approval requests for testing
unless Approval.exists?
  puts "Creating sample approval requests..."
  
  # Sample approval 1 - Pending
  approval1 = Approval.create!(
    email: 'approver1@example.com,approver2@example.com',
    description: 'Budget approval for Q1 2024 marketing campaign',
    action_id: 'marketing-budget-q1-2024',
    callback_url: 'https://example.com/callback/marketing-budget',
    details: {
      amount: 50000,
      department: 'Marketing',
      requester: 'John Smith',
      requester_email: 'john.smith@example.com',
      project: 'Q1 2024 Marketing Campaign',
      budget_category: 'Advertising'
    },
    status: 'pending',
    expire_at: 7.days.from_now
  )
  
  # Sample approval 2 - Approved
  approval2 = Approval.create!(
    email: 'cto@example.com',
    description: 'Server infrastructure upgrade approval',
    action_id: 'infrastructure-upgrade-2024',
    callback_url: 'https://example.com/callback/infrastructure',
    details: {
      amount: 25000,
      department: 'IT',
      requester: 'Jane Doe',
      requester_email: 'jane.doe@example.com',
      project: 'Infrastructure Upgrade 2024',
      servers: 5,
      vendor: 'AWS'
    },
    status: 'approved',
    signature: 'Chief Technology Officer',
    processed_at: 2.days.ago,
    expire_at: 5.days.from_now
  )
  
  # Sample approval 3 - Rejected
  approval3 = Approval.create!(
    email: 'finance@example.com',
    description: 'Travel expense approval for conference',
    action_id: 'travel-expense-conf-2024',
    callback_url: 'https://example.com/callback/travel',
    details: {
      amount: 3500,
      department: 'Sales',
      requester: 'Mike Johnson',
      requester_email: 'mike.johnson@example.com',
      destination: 'New York',
      conference: 'Tech Conference 2024',
      duration: '3 days'
    },
    status: 'rejected',
    signature: 'Finance Manager',
    processed_at: 1.day.ago,
    expire_at: 3.days.from_now
  )
  
  puts "✓ Created sample approval requests:"
  puts "  - Pending: #{approval1.id}"
  puts "  - Approved: #{approval2.id}"
  puts "  - Rejected: #{approval3.id}"
end

# Test email configuration
if ENV['SMTP_HOST'].present? && ENV['SMTP_USERNAME'].present?
  puts "✓ Email configuration detected"
  
  # Test email sending
  begin
    if Rails.env.development?
      EmailService.test_email_configuration
      puts "✓ Email configuration test successful"
    end
  rescue => e
    puts "⚠ Email configuration test failed: #{e.message}"
  end
else
  puts "⚠ Email configuration incomplete - set SMTP_HOST and SMTP_USERNAME"
end

# Display system information
puts ""
puts "System Information:"
puts "=================="
puts "Rails Environment: #{Rails.env}"
puts "MongoDB Database: #{Mongoid.default_client.database.name}"
puts "Total Users: #{User.count}"
puts "Total Approvals: #{Approval.count}"
puts "Pending Approvals: #{Approval.pending.count}"
puts "Approved Approvals: #{Approval.approved.count}"
puts "Rejected Approvals: #{Approval.rejected.count}"
puts ""
puts "Default Admin User:"
puts "Email: admin@approvalworkflow.com"
puts "Password: admin123"
puts ""
puts "Sample User:"
puts "Email: user@approvalworkflow.com"
puts "Password: user123"
puts ""
puts "Seeding completed successfully!"
