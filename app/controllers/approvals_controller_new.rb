class ApprovalsController < ApplicationController
  before_action :set_approval, only: [:show, :approve, :reject]

  def index
    @approvals = Approval.all.order(created_at: :desc).limit(20)
  end

  def show
    # Approval is set by before_action
  end

  def new
    @approval = Approval.new
  end

  def create
    @approval = Approval.new(approval_params)
    @approval.status = 'pending'
    @approval.expire_at = 7.days.from_now
    
    if @approval.save
      # Send notification email
      begin
        ApprovalMailer.approval_request(@approval).deliver_now
        flash[:success] = 'Solicitação de aprovação enviada com sucesso!'
      rescue => e
        flash[:warning] = "Solicitação criada, mas houve erro ao enviar email: #{e.message}"
      end
      
      redirect_to @approval
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    if @approval.status == 'pending'
      @approval.update!(
        status: 'approved',
        processed_at: Time.current,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      
      # Log the approval
      ApprovalLog.create!(
        approval: @approval,
        status: 'approved',
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current
      )
      
      # Send confirmation email
      begin
        ApprovalMailer.approval_completed(@approval).deliver_now
      rescue => e
        Rails.logger.error "Failed to send approval email: #{e.message}"
      end
      
      flash[:success] = 'Aprovação confirmada com sucesso!'
    else
      flash[:error] = 'Esta solicitação não pode ser aprovada.'
    end
    
    redirect_to @approval
  end

  def reject
    if @approval.status == 'pending'
      @approval.update!(
        status: 'rejected',
        processed_at: Time.current,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      
      # Log the rejection
      ApprovalLog.create!(
        approval: @approval,
        status: 'rejected',
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current
      )
      
      # Send confirmation email
      begin
        ApprovalMailer.approval_completed(@approval).deliver_now
      rescue => e
        Rails.logger.error "Failed to send rejection email: #{e.message}"
      end
      
      flash[:success] = 'Aprovação rejeitada.'
    else
      flash[:error] = 'Esta solicitação não pode ser rejeitada.'
    end
    
    redirect_to @approval
  end

  private

  def set_approval
    @approval = Approval.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Aprovação não encontrada.'
    redirect_to approvals_path
  end

  def approval_params
    params.require(:approval).permit(:description, :action_id, :requester_email, :approver_email, :callback_url, details: {})
  end
end
