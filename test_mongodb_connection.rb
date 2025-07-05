#!/usr/bin/env ruby

# Script to test MongoDB connection with the correct database
require 'bundler/setup'
require 'mongoid'

# Test MongoDB connection with the correct database
mongodb_uri = "mongodb+srv://sousaigor:zRFWDklR6NiE3UOI@cluster0.qjyol.mongodb.net/kaefer_approval?retryWrites=true&w=majority&appName=Cluster0"

puts "Testing MongoDB connection..."
puts "URI: #{mongodb_uri}"
puts "Database name from URI: #{mongodb_uri.split('/').last.split('?').first}"

# Configure Mongoid with the test URI
Mongoid.configure do |config|
  config.clients.default = {
    uri: mongodb_uri,
    options: {
      server_selection_timeout: 30,
      wait_queue_timeout: 15,
      connect_timeout: 15,
      socket_timeout: 15,
      max_pool_size: 20,
      min_pool_size: 1
    }
  }
end

begin
  # Test connection
  client = Mongoid::Clients.default
  client.database.command(ping: 1)
  puts "✅ Connection successful!"
  puts "Database name: #{client.database.name}"
  
  # Test collections
  collections = client.database.collection_names
  puts "Available collections: #{collections}"
  
  # Test if we can access the User collection
  if collections.include?('users')
    user_count = client['users'].count_documents
    puts "User count: #{user_count}"
    
    # List first few users (email only for privacy)
    users = client['users'].find.limit(3).to_a
    puts "Sample users:"
    users.each do |user|
      puts "  - Email: #{user['email']}"
    end
  else
    puts "⚠️  No 'users' collection found"
  end
  
rescue => e
  puts "❌ Connection failed: #{e.message}"
  puts "Error details: #{e.backtrace.first(3)}"
end
