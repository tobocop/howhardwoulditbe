PlinkPivotal::Application.routes.draw do
  resources :registrations, only: [:new, :create]
  resource :session, only: [:new, :create, :destroy]
  resources :offers, only: :index

  match '/account', to: 'accounts#show', as: :account, via: :get
  match '/handle_gigya_login', to: 'gigya_login_handler#create', as: :gigya_login_handler, via: :get
  match '/refer/:user_id/aid/:affiliate_id', to: 'referrals#create', as: :referrer, via: :get


  match "/style_guide", to: "style_guide#show", via: :get
  match '/dashboard', to: "dashboard#show", via: :get
  root to: "home#index", via: :get
end
