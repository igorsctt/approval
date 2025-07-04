# API V1 Approvals Controller

class Api::V1::ApprovalsController < Api::BaseController
  before_action :set_approval, only: [:show, :logs]
  
  # GET /api/v1/approvals/validate?token=...
  def validate_token
    token = params[:token]
    
    if token.blank?
      return error_response('Token is required', :bad_request)
    end
    
    result = ApprovalService.validate_token(token)
    
    if result[:success]
      success_response(result[:data], 'Token is valid')
    else
      error_response(result[:message], result[:status] || :bad_request)
    end
  end
  
  # POST /api/v1/approvals
  def create
    result = ApprovalService.create_approval(approval_params, extract_client_info)
    
    if result[:success]
      success_response(result[:data], 'Approval request created successfully', :created)
    else
      error_response(result[:message], result[:status] || :bad_request, result[:errors])
    end
  end
  
  # GET /api/v1/approvals
  def index
    email = params[:email]
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    
    if email.blank?
      return error_response('Email parameter is required', :bad_request)
    end
    
    approvals = Approval.by_email(email)
                       .recent
                       .page(page)
                       .per(per_page)
    
    paginated_response(approvals, ApprovalSerializer)
  end
  
  # GET /api/v1/approvals/:id
  def show
    success_response(ApprovalSerializer.new(@approval).as_json)
  end
  
  # GET /api/v1/approvals/:id/logs
  def logs
    logs = @approval.approval_logs.recent
    success_response(logs.map { |log| ApprovalLogSerializer.new(log).as_json })
  end
  
  # PUT /api/v1/approvals/approve
  def approve
    token = params[:token]
    signature = params[:signature]
    
    if token.blank?
      return error_response('Token is required', :bad_request)
    end
    
    result = ApprovalService.approve_request(token, signature, extract_client_info)
    
    if result[:success]
      success_response(result[:data], 'Approval request approved successfully')
    else
      error_response(result[:message], result[:status] || :bad_request)
    end
  end
  
  # PUT /api/v1/approvals/reject
  def reject
    token = params[:token]
    signature = params[:signature]
    reason = params[:reason]
    
    if token.blank?
      return error_response('Token is required', :bad_request)
    end
    
    result = ApprovalService.reject_request(token, signature, reason, extract_client_info)
    
    if result[:success]
      success_response(result[:data], 'Approval request rejected successfully')
    else
      error_response(result[:message], result[:status] || :bad_request)
    end
  end
  
  private
  
  def set_approval
    @approval = Approval.find(params[:id])
  end
  
  def approval_params
    params.require(:approval).permit(
      :email,
      :description,
      :action_id,
      :callback_url,
      :expire_in_hours,
      login_config: {},
      details: {}
    )
  end
end
