Rails.application.routes.draw do
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resource :business, only: %i(show)
  resources :portfolios, only: %i(show)
  resources :trades, only: %i(new create)
end
