#!/usr/bin/env ruby

# Simple test to check if Rails loads without errors
puts "Loading Rails environment..."

begin
  require_relative 'config/environment'
  puts "✅ Rails loaded successfully!"
  puts "✅ Environment: #{Rails.env}"
  puts "✅ Application name: #{Rails.application.class.name}"
rescue => e
  puts "❌ Error loading Rails: #{e.message}"
  puts "❌ Backtrace:"
  puts e.backtrace[0..10].join("\n")
end
