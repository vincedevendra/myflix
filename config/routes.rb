Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root to: 'videos#index'

  get '/sign_in', to: 'sessions#new'
  get '/sign_out', to: 'sessions#destroy'

  get '/register', to: 'users#new'
  
  get '/welcome', to: 'pages#welcome' 
  get '/category/:id', to: 'categories#show', as: 'category'

  get '/my_queue', to: 'queue_items#index', as: 'queue'

  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end
    resources :reviews, only: :create
    resources :queue_items, only: :create
  end

  resources :queue_items, only: [:destroy]
#Not worried about this yet:
  # patch :update_queue, to: 'queue_items#update'
  # put :update_queue, to: 'queue_items#update'

  resources :users, only: :create
  resources :sessions, only: :create
end
