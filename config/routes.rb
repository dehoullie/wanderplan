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
      get "places", to: "places#index"
      post "trips/plan", to: "trips#plan"
      get 'itineraries/gallery', to: 'itineraries#gallery'
      resources :itineraries, only: [:show] do
        collection do
          get :find_existing
        end
      end
    end
  end

end
