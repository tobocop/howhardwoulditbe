PlinkPivotal::Application.routes.draw do

  mount PlinkAdmin::Engine => '/plink_admin'

  resource :account, only: [:show, :update], controller: :accounts

  resources :registrations, only: [:new, :create]
  resources :offers, only: :index
  resource :session, only: [:new, :create, :destroy], as: :plink_session
  resource :tracking, only: [:new], controller: 'tracking'

  resources :rewards, only: [:index]

  resource :wallet, only: [:show] do
    resources :offers, only: [:create, :destroy], controller: 'wallet_offers'
  end

  resources :redemptions, only: [:create]

  resource :contact, controller: 'contact', only: [:create] do
    get :new
    get :thank_you
  end

  resource :password_reset_request, only: [:new, :create], controller: :password_reset_request
  resource :password_reset, only: [:new, :create], controller: :password_reset

  match '/handle_gigya_login', to: 'gigya_login_handler#create', as: :gigya_login_handler, via: :get
  match '/refer/:user_id/aid/:affiliate_id', to: 'referrals#create', as: :referrer, via: :get

  match "/style_guide", to: "style_guide#show", via: :get
  match '/dashboard', to: "dashboard#show", via: :get

  root to: "home#index", via: :get
end
