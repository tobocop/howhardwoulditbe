PlinkAdmin::Engine.routes.draw do

  devise_for :admins, :class_name => "PlinkAdmin::Admin", skip: [:passwords, :registrations, :unlock], module: :devise

  resources :hero_promotions

  resources :users, only: [:index] do
    get :search, on: :collection
    post :impersonate, on: :member
    post :stop_impersonating, on: :member
  end

  root to: 'admin#home'
end
