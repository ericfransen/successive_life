Rails.application.routes.draw do
  root 'welcome#index'
  resources :goals, only: [:index]
  resources :github_goals
  # resources :goodreads, except: [:create, ]

  get '/login'     => redirect('/auth/twitter'), as: :login
  get '/goodreads' => redirect('/auth/goodreads'), as: :new_goodread
  get '/fitbit' => redirect('/auth/fitbit'), as: :fitbit
  get '/auth/goodreads/callback', to: 'goodreads#create'

  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/auth/fitbit/callback', to: 'fitbit#create'

end
