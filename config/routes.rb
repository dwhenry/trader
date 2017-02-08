Rails.application.routes.draw do
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'about', to: 'home#about', as: 'about'

  resource :business, only: %i(show new create)
  resource :config, only: %i(show update) do
    resource :business, only: %i(update)
    resources :fields, only: %i(new create edit destroy)
    resources :portfolios, only: %i(update create)
    resources :users, only: %i(update create)
  end
  resources :events, only: %i(index)
  resources :portfolios, only: %i(show)
  resources :securities, only: %i(create show) do
    resources :prices, only: %i(index)
  end
  resources :trades, only: %i(new create edit update)
  resource :user_setup, only: %i(new create) do
    collection do
      get :business
      get :portfolio
    end
  end
  resource :yahoo_security_search, only: %i(show create)
end
