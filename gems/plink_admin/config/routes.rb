PlinkAdmin::Engine.routes.draw do

  devise_for :admins, :class_name => "PlinkAdmin::Admin", skip: [:passwords, :registrations, :unlock], module: :devise

  resources :hero_promotions, except: :destroy
  resources :campaigns, except: :destroy

  resources :users, only: [:index] do
    get :search, on: :collection
    get :edit, on: :member
    post :impersonate, on: :member
    post :stop_impersonating, on: :member
  end

  resources :wallet_items, except: :destroy do
    post :unlock_wallet_item_with_reason, on: :member
  end

  resources :contests do
    get :search, on: :collection
    get :stats
    post :entries
  end

  root to: 'admin#home'
end
