PlinkAdmin::Engine.routes.draw do

  devise_for :admins, :class_name => "PlinkAdmin::Admin", skip: [:passwords, :registrations, :unlock], module: :devise

  resources :hero_promotions, except: :destroy do
    get :edit_audience, to: 'hero_promotions#edit_audience', on: :member
    put :update_audience, to: 'hero_promotions#update_audience', on: :member
  end
  resources :affiliates, except: :destroy
  resources :brands, except: :destroy
  resources :campaigns, except: :destroy
  resources :contacts, except: :destroy
  resources :global_login_tokens, except: :destroy
  resources :landing_pages, except: :destroy
  resources :receipt_promotions, except: :destroy
  resources :receipt_submissions, only: [:index, :update]
  resources :award_links, except: :destroy

  resources :receipt_submission_queue, only: [:show]

  resources :share_pages, except: :destroy
  resources :registration_links, except: [:destroy] do
    get :share_statistics, on: :member
  end
  resources :users_institution_accounts, only: :destroy
  resources :offers, only: [:index, :edit, :update]

  resources :users, only: [:index, :update] do
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

  get '/tango/kill_switch', to: 'tango#kill_switch', as: 'tango_kill_switch'
  post '/tango/toggle_redeemable', to: 'tango#toggle_redeemable', as: 'tango_toggle_redeemable'

  root to: 'admin#home'
end
