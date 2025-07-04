class HomeController < ApplicationController
  def index
    @total_approvals = Approval.count
    @pending_approvals = Approval.where(status: 'pending').count
    @approved_approvals = Approval.where(status: 'approved').count
    @rejected_approvals = Approval.where(status: 'rejected').count
    @recent_approvals = Approval.limit(5).order(created_at: :desc)
  end
end
