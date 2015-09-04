Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root to: 'videos#index'

  get '/sign_in', to: 'sessions#new'
  get '/sign_out', to: 'sessions#destroy'
  get '/register', to: 'users#new'
  get '/welcome', to: 'pages#welcome'
  get '/my_queue', to: 'queue_items#index', as: 'queue'
  post '/update_queue', to: 'queue_items#update'
  get '/people', to: 'followings#index'

  get '/forgot_password', to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]
  get '/reset_password/:token', to: 'forgot_passwords#edit', as: 'reset_password'
  patch '/update_password', to: 'forgot_passwords#update'
  get '/confirm_password_reset', to: 'forgot_passwords#show'

  get '/invalid_token', to: 'pages#invalid_token'

  resources :followings, only: [:create, :destroy]
  resources :categories, only: :show
  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end
    resources :reviews, only: :create
    resources :queue_items, only: :create
  end

  resources :queue_items, only: [:destroy] do
    member do
      post 'top'
    end
  end

  resources :users, only: [:create, :show]
  resources :sessions, only: :create

  resources :invites, only: [:new, :create]
  get '/invalid_link', to: 'pages#invalid_link'

  namespace :admin do
    resources :videos, only: [:new, :create]
    resources :payments, only: :index
  end

  mount StripeEvent::Engine, at: '/stripe_events'
end
