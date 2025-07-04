#!/usr/bin/env ruby

# Simple Sinatra-based server for testing the approval system
require 'sinatra'
require 'json'
require 'mongoid'
require 'jwt'
require 'mail'
require 'rack/cors'

# Configure Mongoid
Mongoid.load!('./config/mongoid.yml', :development)

# Configure CORS
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
  end
end

# Load models
require './app/models/approval.rb'
require './app/models/approval_log.rb'
require './app/models/user.rb'

# Load services
require './app/services/jwt_service.rb'
require './app/services/approval_service.rb'

# Helper function to check MongoDB connection
def mongo_connected?
  begin
    Mongoid.default_client.database.command(ping: 1)
    true
  rescue
    false
  end
end

set :port, 3000
set :bind, '0.0.0.0'

get '/' do
  content_type :json
  { 
    message: 'Approval Workflow API',
    version: '1.0.0',
    status: 'running',
    mongodb_connected: mongo_connected?,
    timestamp: Time.current.iso8601
  }.to_json
end

get '/health' do
  content_type :json
  {
    status: 'healthy',
    mongodb: mongo_connected? ? 'connected' : 'disconnected',
    timestamp: Time.current.iso8601
  }.to_json
end

# Test endpoint to create approval
post '/api/v1/approvals' do
  content_type :json
  
  begin
    data = JSON.parse(request.body.read)
    
    approval = Approval.create!(
      description: data['description'],
      action_id: data['action_id'],
      requester_email: data['requester_email'],
      approver_email: data['approver_email'],
      status: 'pending',
      expire_at: Time.current + 7.days,
      details: data['details'] || {}
    )
    
    {
      success: true,
      data: {
        id: approval.id.to_s,
        description: approval.description,
        action_id: approval.action_id,
        status: approval.status,
        created_at: approval.created_at.iso8601
      }
    }.to_json
  rescue => e
    status 422
    { success: false, error: e.message }.to_json
  end
end

# Get approval by ID
get '/api/v1/approvals/:id' do
  content_type :json
  
  begin
    approval = Approval.find(params[:id])
    {
      success: true,
      data: {
        id: approval.id.to_s,
        description: approval.description,
        action_id: approval.action_id,
        status: approval.status,
        requester_email: approval.requester_email,
        approver_email: approval.approver_email,
        created_at: approval.created_at.iso8601,
        expire_at: approval.expire_at.iso8601,
        details: approval.details
      }
    }.to_json
  rescue Mongoid::Errors::DocumentNotFound
    status 404
    { success: false, error: 'Approval not found' }.to_json
  rescue => e
    status 500
    { success: false, error: e.message }.to_json
  end
end

# List all approvals
get '/api/v1/approvals' do
  content_type :json
  
  begin
    approvals = Approval.all.limit(50).map do |approval|
      {
        id: approval.id.to_s,
        description: approval.description,
        action_id: approval.action_id,
        status: approval.status,
        requester_email: approval.requester_email,
        approver_email: approval.approver_email,
        created_at: approval.created_at.iso8601,
        expire_at: approval.expire_at.iso8601
      }
    end
    
    {
      success: true,
      data: approvals,
      count: approvals.length
    }.to_json
  rescue => e
    status 500
    { success: false, error: e.message }.to_json
  end
end

# Test MongoDB connection
get '/test/mongodb' do
  content_type :json
  
  begin
    # Test connection by counting documents
    count = Approval.count
    
    {
      success: true,
      mongodb_connected: true,
      approvals_count: count,
      database_name: Mongoid.default_client.database.name
    }.to_json
  rescue => e
    {
      success: false,
      mongodb_connected: false,
      error: e.message
    }.to_json
  end
end

puts "🚀 Starting Approval Workflow Server on port 3000..."
puts "📊 MongoDB: #{mongo_connected? ? 'Connected' : 'Disconnected'}"
puts "🔗 API endpoints:"
puts "   GET  /             - API info"
puts "   GET  /health       - Health check"
puts "   GET  /test/mongodb - MongoDB test"
puts "   POST /api/v1/approvals - Create approval"
puts "   GET  /api/v1/approvals - List approvals"
puts "   GET  /api/v1/approvals/:id - Get approval"
puts ""
