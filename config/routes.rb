Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  root 'players#index'
  resources :players, only: [:index]
  resources :frames, only: [:create, :destroy]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
