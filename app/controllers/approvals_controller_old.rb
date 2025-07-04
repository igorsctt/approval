# Web Approvals Controller for handling web-based approval pages

class ApprovalsController < ApplicationController
  before_action :set_approval_from_token, only: [:show, :update]
  
  # GET /approve?token=...
  def show
    token = params[:token]
    
    if token.blank?
      redirect_to root_path, alert: 'Invalid approval link'
      return
    end
    
    result = ApprovalService.validate_token(token)
    
    if result[:success]
      @approval = result[:data]
      @token = token
      render 'approvals/show'
    else
      redirect_to root_path, alert: result[:message]
    end
  end
  
  # POST /approve
  def update
    token = params[:token]
    action = params[:action_type] # 'approve' or 'reject'
    signature = params[:signature]
    reason = params[:reason]
    
    if token.blank?
      redirect_to root_path, alert: 'Invalid approval link'
      return
    end
    
    result = case action
             when 'approve'
               ApprovalService.approve_request(token, signature, extract_client_info)
             when 'reject'
               ApprovalService.reject_request(token, signature, reason, extract_client_info)
             else
               { success: false, message: 'Invalid action' }
             end
    
    if result[:success]
      redirect_to approve_path(token: token), notice: "Approval request #{action}d successfully"
    else
      redirect_to approve_path(token: token), alert: result[:message]
    end
  end
  
  private
  
  def set_approval_from_token
    token = params[:token]
    return unless token
    
    result = ApprovalService.validate_token(token)
    @approval = result[:data] if result[:success]
  end
end
