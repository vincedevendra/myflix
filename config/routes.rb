Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root to: 'users#front'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/register', to: 'users#new'

  get '/home', to: 'users#home' 
  get '/category/:id', to: 'categories#show', as: 'category'
  
  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end
  end

  resources :users, except: [:index, :destroy], path_names: {new: 'register'}
end
