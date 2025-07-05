#!/usr/bin/env ruby

# MongoDB URI Validator and Tester
# This script helps validate and test different MongoDB URIs

require 'uri'

def validate_mongodb_uri(uri_string)
  puts '🔍 Analyzing MongoDB URI...'
  puts "URI: #{uri_string}"
  puts

  begin
    # Parse the URI
    uri = URI.parse(uri_string)

    # Extract components
    scheme = uri.scheme
    username = uri.user
    password = uri.password
    host = uri.host
    port = uri.port
    path = uri.path
    query = uri.query

    # Extract database name
    database_name = path.split('/').last if path && !path.empty?

    puts '📋 URI Components:'
    puts "  Scheme: #{scheme}"
    puts "  Username: #{username}"
    puts "  Password: #{'*' * password.length if password}"
    puts "  Host: #{host}"
    puts "  Port: #{port}" if port
    puts "  Path: #{path}"
    puts "  Database: #{database_name || 'NOT SPECIFIED'}"
    puts "  Query: #{query}" if query
    puts

    # Validate components
    errors = []

    errors << "❌ Invalid scheme: #{scheme}" unless ['mongodb', 'mongodb+srv'].include?(scheme)
    errors << '❌ Username missing' unless username
    errors << '❌ Password missing' unless password
    errors << '❌ Host missing' unless host
    errors << '❌ Database name missing' unless database_name && !database_name.empty?

    if errors.empty?
      puts '✅ URI appears valid!'
      puts "✅ Will connect to database: #{database_name}"
    else
      puts '❌ URI validation errors:'
      errors.each { |error| puts "  #{error}" }
    end

    database_name
  rescue StandardError => e
    puts "❌ Failed to parse URI: #{e.message}"
    nil
  end
end

def compare_uris(uri1, uri2)
  puts "\n" + '=' * 60
  puts '🔄 COMPARING URIs'
  puts '=' * 60

  puts "\n1️⃣ FIRST URI:"
  db1 = validate_mongodb_uri(uri1)

  puts "\n2️⃣ SECOND URI:"
  db2 = validate_mongodb_uri(uri2)

  puts "\n📊 COMPARISON RESULTS:"
  if db1 && db2
    if db1 == db2
      puts "✅ Both URIs point to the same database: #{db1}"
    else
      puts '⚠️  URIs point to different databases:'
      puts "    First URI database:  #{db1}"
      puts "    Second URI database: #{db2}"
    end
  else
    puts '❌ Cannot compare - one or both URIs are invalid'
  end
end

# Test the provided URI
puts 'MongoDB URI Validator and Tester'
puts '=' * 50

# The correct URI that should be used - MongoDB Atlas
correct_uri = 'mongodb+srv://kaefer_user:KaeferApproval2024!@kaefer-approval.i3rewq4.mongodb.net/kaefer_approval?retryWrites=true&w=majority'

# A test URI that might be wrong (points to test database)
wrong_uri = 'mongodb+srv://kaefer_user:KaeferApproval2024!@kaefer-approval.i3rewq4.mongodb.net/test?retryWrites=true&w=majority'

puts "\n🎯 TESTING CORRECT URI:"
validate_mongodb_uri(correct_uri)

puts "\n⚠️  EXAMPLE OF WRONG URI (for comparison):"
validate_mongodb_uri(wrong_uri)

compare_uris(correct_uri, wrong_uri)

puts "\n" + '=' * 60
puts '📝 SUMMARY'
puts '=' * 60
puts '✅ Your correct URI should connect to: kaefer_approval'
puts '❌ Wrong URI would connect to: test'
puts "\nMake sure your Render environment variable MONGODB_URI is set to:"
puts correct_uri
