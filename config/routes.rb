Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Authentication routes
  get 'login', to: 'auth#login'
  post 'authenticate', to: 'auth#authenticate'
  post 'debug_auth', to: 'auth#debug_auth' # Debug route temporário
  get 'check_env', to: 'auth#check_env' # Check environment variables
  delete 'logout', to: 'auth#logout'
  get 'logout', to: 'auth#logout'

  # Root route
  root 'auth#login'

  # User management routes (admin only)
  resources :users do
    member do
      patch :toggle_status
    end
  end

  # Health check endpoint
  get 'health', to: 'health#show'

  # Web routes for approvals
  resources :approvals do
    member do
      patch :approve
      patch :reject
      get :approve
      get :reject
    end
  end

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/login', to: 'auth#login'
      post 'auth/validate', to: 'auth#validate'
      
      # Approval routes
      resources :approvals, only: [:create, :index, :show] do
        collection do
          get 'validate', to: 'approvals#validate_token'
          put 'approve', to: 'approvals#approve'
          put 'reject', to: 'approvals#reject'
        end
        
        member do
          get 'logs', to: 'approvals#logs'
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
