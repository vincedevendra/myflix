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
end
