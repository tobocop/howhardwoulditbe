PlinkAdmin::Engine.routes.draw do

  devise_for :admins, :class_name => "PlinkAdmin::Admin", skip: [:passwords, :registrations, :unlock], module: :devise

  resources :hero_promotions, except: :destroy
  resources :affiliates, except: :destroy
  resources :campaigns, except: :destroy
  resources :landing_pages, except: :destroy
  resources :share_pages, except: :destroy
  resources :registration_links, except: [:destroy] do
    get :share_statistics, on: :member
  end
  resources :offers, only: [:index, :edit, :update]

  resources :users, only: [:index] do
    get :search, on: :collection
    get :edit, on: :member
    post :impersonate, on: :member
    post :stop_impersonating, on: :member
  end

  resources :wallet_items, except: :destroy do
    post :unlock_wallet_item_with_reason, on: :member
    post :give_open_wallet_item_with_reason, on: :member
  end

  resources :contests do
    get :search, on: :collection
    get :user_entry_stats
    post :entries
    get :statistics
    get :winners
    get :remove_winner
    post :accept_winners
  end

  root to: 'admin#home'
end
