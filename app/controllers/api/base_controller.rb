# Base API Controller

class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  before_action :set_cors_headers
  
  protected
  
  def success_response(data, message = nil, status = :ok)
    response = {
      status: 'success',
      data: data
    }
    response[:message] = message if message
    
    render json: response, status: status
  end
  
  def error_response(message, status = :bad_request, errors = nil)
    response = {
      status: 'error',
      message: message
    }
    response[:errors] = errors if errors
    
    render json: response, status: status
  end
  
  def paginated_response(collection, serializer = nil, meta = {})
    data = if serializer
      collection.map { |item| serializer.new(item).as_json }
    else
      collection.as_json
    end
    
    response = {
      status: 'success',
      data: data,
      meta: {
        total: collection.respond_to?(:total_count) ? collection.total_count : collection.size,
        page: collection.respond_to?(:current_page) ? collection.current_page : 1,
        per_page: collection.respond_to?(:limit_value) ? collection.limit_value : collection.size
      }.merge(meta)
    }
    
    render json: response, status: :ok
  end

  private
  
  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = '1728000'
  end
end
