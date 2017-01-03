Rails.application.routes.draw do
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'about', to: 'home#about', as: 'about'

  resource :business, only: %i(show new create)
  resources :portfolios, only: %i(show)
  resource :config, only: %i(show update) do
    resources :users, only: %i(update create)
    resource :business, only: %i(update)
    resources :portfolios, only: %i(update create)
  end
  resources :trades, only: %i(new create edit update)
  resource :user_setup, only: %i(new create) do
    collection do
      get :business
      get :portfolio
    end
  end
end
