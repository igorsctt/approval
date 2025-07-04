class UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_status]

  def index
    @users = User.all.order(created_at: :desc)
    @admin_count = User.admins.count
    @user_count = User.users.count
    @active_count = User.active.count
  end

  def show
    # User is set by before_action
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      redirect_to users_path, notice: 'Usuário criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # User is set by before_action
  end

  def update
    # Remove password do params se estiver vazio
    if params[:user][:password].blank?
      params[:user].delete(:password)
    end
    
    if @user.update(user_params)
      redirect_to @user, notice: 'Usuário atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: 'Você não pode excluir sua própria conta.'
      return
    end
    
    @user.destroy
    redirect_to users_path, notice: 'Usuário excluído com sucesso!'
  end

  def toggle_status
    @user.update!(active: !@user.active?)
    status_text = @user.active? ? 'ativado' : 'desativado'
    redirect_to users_path, notice: "Usuário #{status_text} com sucesso!"
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to users_path, alert: 'Usuário não encontrado.'
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :active, :password)
  end
end
