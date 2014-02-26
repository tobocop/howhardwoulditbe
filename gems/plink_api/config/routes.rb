PlinkApi::Engine.routes.draw do
  namespace :v1, defaults: {format: 'json'} do
    root to: 'api#home'
    resources :sendgrid_events, only: [:create]
  end
end
