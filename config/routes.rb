Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # config/routes.rb
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        get 'me', to: 'sessions#me'
      end
      get "places", to: "places#index"
      post "trips/plan", to: "trips#plan"
      get 'itineraries/gallery', to: 'itineraries#gallery'
      resources :itineraries, only: [:show] do
        collection do
          get :find_existing
        end
      end

      devise_for :users,
      controllers: {
        registrations: 'api/v1/registrations',
        sessions: 'api/v1/sessions'
      },
      path: '',
      path_names: {
        sign_in: 'login',
        sign_out: 'logout',
        registration: 'register'
      }
      # get :me, to: 'sessions#me'

    end
  end

end
