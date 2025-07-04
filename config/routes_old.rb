# Routes Configuration

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoint
  get 'health', to: 'health#show'

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

  # Web routes for approval pages
  get 'approve', to: 'approvals#show'
  post 'approve', to: 'approvals#update'
  
  # Root route
  root 'application#index'

  # Catch-all route for SPA
  get '*path', to: 'application#index', constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
