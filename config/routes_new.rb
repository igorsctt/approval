Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route
  root 'home#index'

  # Health check endpoint
  get 'health', to: 'health#show'

  # Web routes for approvals
  resources :approvals do
    member do
      patch :approve
      patch :reject
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
