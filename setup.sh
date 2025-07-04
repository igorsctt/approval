#!/bin/bash

# Setup script for Approval Workflow Ruby on Rails Application

set -e

echo "🚀 Setting up Approval Workflow System..."

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby is not installed. Please install Ruby 3.4.4 first."
    exit 1
fi

# Check Ruby version
RUBY_VERSION=$(ruby -v | cut -d' ' -f2)
echo "✅ Ruby version: $RUBY_VERSION"

# Check if Bundle is installed
if ! command -v bundle &> /dev/null; then
    echo "📦 Installing Bundler..."
    gem install bundler
fi

# Install dependencies
echo "📦 Installing Ruby dependencies..."
bundle install

# Check if MongoDB is running
if ! pgrep mongod > /dev/null; then
    echo "🔄 Starting MongoDB..."
    # Try to start MongoDB using different methods
    if command -v systemctl &> /dev/null; then
        sudo systemctl start mongod
    elif command -v service &> /dev/null; then
        sudo service mongod start
    elif command -v brew &> /dev/null; then
        brew services start mongodb/brew/mongodb-community
    else
        echo "⚠️  Please start MongoDB manually"
        echo "   - Ubuntu/Debian: sudo systemctl start mongod"
        echo "   - macOS: brew services start mongodb-community"
        echo "   - Or use Docker: docker run -d -p 27017:27017 mongo:7.0"
    fi
fi

# Wait for MongoDB to be ready
echo "⏳ Waiting for MongoDB to be ready..."
sleep 3

# Setup environment variables
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ .env file created. Please edit it with your configuration."
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Create database indexes
echo "📊 Creating database indexes..."
bundle exec rails runner "
  Approval.create_indexes
  ApprovalLog.create_indexes
  User.create_indexes
  puts '✅ Database indexes created'
"

# Seed the database
echo "🌱 Seeding database..."
bundle exec rails db:seed

# Precompile assets
echo "🎨 Precompiling assets..."
bundle exec rails assets:precompile

# Test email configuration
echo "📧 Testing email configuration..."
bundle exec rails runner "
  if ENV['SMTP_HOST'].present? && ENV['SMTP_USERNAME'].present?
    if EmailService.test_email_configuration
      puts '✅ Email configuration test passed'
    else
      puts '⚠️  Email configuration test failed'
    end
  else
    puts '⚠️  Email configuration incomplete'
  end
"

# Run health check
echo "🏥 Running health check..."
bundle exec rake approval:health_check

# Display system information
echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "System Information:"
echo "=================="
echo "MongoDB: $(mongod --version | head -1)"
echo "Rails: $(rails -v)"
echo "Environment: $(rails runner 'puts Rails.env')"
echo ""
echo "Available Commands:"
echo "=================="
echo "Start server:           rails server"
echo "Create approval:        rake approval:create_sample"
echo "Cleanup expired:        rake approval:cleanup_expired"
echo "Send reminders:         rake approval:send_reminders"
echo "View statistics:        rake approval:stats"
echo "Health check:           rake approval:health_check"
echo "Test email:             rake approval:test_email"
echo ""
echo "API Endpoints:"
echo "=============="
echo "Health:                 GET  /health"
echo "Create Approval:        POST /api/v1/approvals"
echo "List Approvals:         GET  /api/v1/approvals?email=user@example.com"
echo "Validate Token:         GET  /api/v1/approvals/validate?token=..."
echo "Approve Request:        PUT  /api/v1/approvals/approve"
echo "Reject Request:         PUT  /api/v1/approvals/reject"
echo ""
echo "Web Interface:"
echo "=============="
echo "Approval Page:          /approve?token=..."
echo ""
echo "Default Admin User:"
echo "==================="
echo "Email:    admin@approvalworkflow.com"
echo "Password: admin123"
echo ""
echo "🚀 Ready to start! Run: rails server"
