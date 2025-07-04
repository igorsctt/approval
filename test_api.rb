# Basic API test script

require 'net/http'
require 'json'
require 'uri'

class ApprovalApiTest
  API_BASE_URL = ENV.fetch('API_BASE_URL', 'http://localhost:3000')
  
  def initialize
    @api_url = API_BASE_URL
    puts "🧪 Testing Approval API at #{@api_url}"
  end
  
  def run_tests
    puts "\n🏁 Starting API Tests..."
    
    # Test 1: Health check
    test_health_check
    
    # Test 2: Create approval
    approval_data = test_create_approval
    
    # Test 3: Validate token
    test_validate_token(approval_data[:token]) if approval_data
    
    # Test 4: List approvals
    test_list_approvals
    
    # Test 5: Approve request
    test_approve_request(approval_data[:token]) if approval_data
    
    puts "\n✅ All tests completed!"
  end
  
  private
  
  def test_health_check
    puts "\n🏥 Testing health check..."
    
    uri = URI("#{@api_url}/health")
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      health_data = JSON.parse(response.body)
      puts "✅ Health check passed"
      puts "   Status: #{health_data['status']}"
      puts "   Services: #{health_data['services'].keys.join(', ')}"
    else
      puts "❌ Health check failed: #{response.code}"
    end
  rescue => e
    puts "❌ Health check error: #{e.message}"
  end
  
  def test_create_approval
    puts "\n📝 Testing create approval..."
    
    uri = URI("#{@api_url}/api/v1/approvals")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      approval: {
        email: 'test@example.com',
        description: 'Test approval request from API test',
        action_id: 'api-test-001',
        callback_url: 'https://httpbin.org/post',
        expire_in_hours: 24,
        details: {
          test: true,
          amount: 1000,
          created_by: 'API Test Script'
        }
      }
    }.to_json
    
    response = http.request(request)
    
    if response.code == '201'
      data = JSON.parse(response.body)
      puts "✅ Approval created successfully"
      puts "   ID: #{data['data']['approval_id']}"
      puts "   URL: #{data['data']['approval_url']}"
      
      # Extract token from URL
      token = data['data']['approval_url'].split('token=').last
      return { token: token, id: data['data']['approval_id'] }
    else
      puts "❌ Create approval failed: #{response.code}"
      puts "   Response: #{response.body}"
      return nil
    end
  rescue => e
    puts "❌ Create approval error: #{e.message}"
    return nil
  end
  
  def test_validate_token(token)
    puts "\n🔍 Testing validate token..."
    
    uri = URI("#{@api_url}/api/v1/approvals/validate?token=#{token}")
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      puts "✅ Token validation passed"
      puts "   Status: #{data['data']['status']}"
      puts "   Can be processed: #{data['data']['can_be_processed']}"
    else
      puts "❌ Token validation failed: #{response.code}"
      puts "   Response: #{response.body}"
    end
  rescue => e
    puts "❌ Token validation error: #{e.message}"
  end
  
  def test_list_approvals
    puts "\n📋 Testing list approvals..."
    
    uri = URI("#{@api_url}/api/v1/approvals?email=test@example.com")
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      puts "✅ List approvals passed"
      puts "   Total: #{data['meta']['total']}"
      puts "   Page: #{data['meta']['page']}"
    else
      puts "❌ List approvals failed: #{response.code}"
      puts "   Response: #{response.body}"
    end
  rescue => e
    puts "❌ List approvals error: #{e.message}"
  end
  
  def test_approve_request(token)
    puts "\n👍 Testing approve request..."
    
    uri = URI("#{@api_url}/api/v1/approvals/approve")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Put.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      token: token,
      signature: 'API Test Script'
    }.to_json
    
    response = http.request(request)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      puts "✅ Approve request passed"
      puts "   Status: #{data['data']['status']}"
      puts "   Signature: #{data['data']['signature']}"
    else
      puts "❌ Approve request failed: #{response.code}"
      puts "   Response: #{response.body}"
    end
  rescue => e
    puts "❌ Approve request error: #{e.message}"
  end
end

# Run tests if this file is executed directly
if __FILE__ == $0
  puts "🚀 Approval Workflow API Test Suite"
  puts "===================================="
  
  # Check if server is running
  begin
    uri = URI("#{ENV.fetch('API_BASE_URL', 'http://localhost:3000')}/health")
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      puts "✅ Server is running"
      
      # Run the tests
      tester = ApprovalApiTest.new
      tester.run_tests
    else
      puts "❌ Server is not responding properly"
      puts "   Make sure the Rails server is running: rails server"
    end
  rescue => e
    puts "❌ Cannot connect to server: #{e.message}"
    puts "   Make sure the Rails server is running: rails server"
  end
end
