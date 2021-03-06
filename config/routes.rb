Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  root 'home#index'
  resources :frames, only: [:create, :destroy, :index]
  resources :players, only: [:show, :create, :index]

  get '/frames/count', to: 'frames#count'
  get '/ev', to: 'elos#ev'

  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end if Rails.env.production?
  mount Sidekiq::Web => '/sidekiq'
end
