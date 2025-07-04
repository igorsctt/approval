class ApprovalsController < ApplicationController
  before_action :set_approval, only: [:show, :approve, :reject]
  before_action :ensure_sample_data, only: [:index]
  
  # Authorization rules
  before_action :require_admin!, only: [:new, :create, :approve, :reject]
  before_action :require_user_or_admin!, only: [:index, :show]

  def index
    @approvals = filter_approvals.order(created_at: :desc).limit(50)
    @filter_params = {
      action_id: params[:action_id],
      status: params[:status],
      date: params[:date],
      title: params[:title]
    }
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
        event: 'approval_approved',
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
    
    redirect_to approvals_path
  end

  def reject
    if @approval.status == 'pending'
      @approval.update!(
        status: 'rejected',
        processed_at: Time.current,
        rejection_reason: params[:rejection_reason],
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      
      # Log the rejection
      ApprovalLog.create!(
        approval: @approval,
        status: 'rejected',
        event: 'approval_rejected',
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current,
        metadata: { rejection_reason: params[:rejection_reason] }
      )
      
      # Send confirmation email
      begin
        ApprovalMailer.approval_completed(@approval).deliver_now
      rescue => e
        Rails.logger.error "Failed to send rejection email: #{e.message}"
      end
      
      flash[:success] = 'Solicitação rejeitada com sucesso.'
    else
      flash[:error] = 'Esta solicitação não pode ser rejeitada.'
    end
    
    redirect_to approvals_path
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

  def filter_approvals
    approvals = Approval.all
    
    # Filtro por código (action_id)
    if params[:action_id].present?
      approvals = approvals.where(action_id: /#{Regexp.escape(params[:action_id])}/i)
    end
    
    # Filtro por status
    if params[:status].present? && params[:status] != 'todos'
      approvals = approvals.where(status: params[:status])
    end
    
    # Filtro por data
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
        start_of_day = date.beginning_of_day
        end_of_day = date.end_of_day
        approvals = approvals.where(created_at: start_of_day..end_of_day)
      rescue Date::Error
        # Data inválida, ignorar filtro
      end
    end
    
    # Filtro por título (description)
    if params[:title].present?
      approvals = approvals.where(description: /#{Regexp.escape(params[:title])}/i)
    end
    
    approvals
  end
  
  def ensure_sample_data
    return if Approval.where(status: 'pending').count >= 5
    
    # Criar dados de exemplo mais realistas
    approvals_data = [
      {
        description: 'Solicitação de compra de equipamentos de TI - Notebooks Dell para equipe de desenvolvimento',
        requested_by: 'Ana Silva',
        requested_by_email: 'ana.silva@kaefer.com',
        amount: 15000.00,
        category: 'TI',
        priority: 'high',
        status: 'pending',
        created_at: 1.hour.ago
      },
      {
        description: 'Contratação de serviços de consultoria externa para Projeto Alpha de automação industrial',
        requested_by: 'Carlos Santos',
        requested_by_email: 'carlos.santos@kaefer.com',
        amount: 25000.00,
        category: 'Consultoria',
        priority: 'medium',
        status: 'pending',
        created_at: 2.hours.ago
      },
      {
        description: 'Renovação de licenças de software Microsoft Office para toda a empresa',
        requested_by: 'Maria José',
        requested_by_email: 'maria.jose@kaefer.com',
        amount: 8000.00,
        category: 'Software',
        priority: 'low',
        status: 'pending',
        created_at: 3.hours.ago
      },
      {
        description: 'Viagem de negócios para Conferência Internacional de Engenharia em Frankfurt',
        requested_by: 'João Pedro',
        requested_by_email: 'joao.pedro@kaefer.com',
        amount: 12000.00,
        category: 'Viagem',
        priority: 'medium',
        status: 'pending',
        created_at: 4.hours.ago
      },
      {
        description: 'Aquisição de materiais de construção para Projeto Beta - Reforma da fábrica',
        requested_by: 'Roberto Lima',
        requested_by_email: 'roberto.lima@kaefer.com',
        amount: 45000.00,
        category: 'Materiais',
        priority: 'high',
        status: 'pending',
        created_at: 5.hours.ago
      },
      {
        description: 'Treinamento de equipe em Certificação de Segurança Industrial NR-10',
        requested_by: 'Fernanda Costa',
        requested_by_email: 'fernanda.costa@kaefer.com',
        amount: 18000.00,
        category: 'Treinamento',
        priority: 'medium',
        status: 'pending',
        created_at: 6.hours.ago
      },
      {
        description: 'Manutenção preventiva de equipamentos industriais - Caldeiras e Compressores',
        requested_by: 'Ricardo Oliveira',
        requested_by_email: 'ricardo.oliveira@kaefer.com',
        amount: 22000.00,
        category: 'Manutenção',
        priority: 'high',
        status: 'pending',
        created_at: 7.hours.ago
      },
      {
        description: 'Compra de uniformes e EPIs para equipe de campo - Capacetes e botas de segurança',
        requested_by: 'Luciana Mendes',
        requested_by_email: 'luciana.mendes@kaefer.com',
        amount: 9500.00,
        category: 'Segurança',
        priority: 'medium',
        status: 'pending',
        created_at: 8.hours.ago
      }
    ]
    
    approvals_data.each do |data|
      approval = Approval.new(data)
      approval.save
    end
  end
end
