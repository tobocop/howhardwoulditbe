PlinkPivotal::Application.routes.draw do
  resource :account, only: [:show, :update], controller: :accounts

  resources :registrations, only: [:new, :create]
  resources :offers, only: :index
  resources :registration_links, only: [:show]
  resource :session, only: [:new, :create, :destroy], as: :plink_session
  resource :tracking, only: [:new], controller: 'tracking'

  resources :rewards, only: [:index]

  resource :wallet, only: [:show] do
    resources :offers, only: [:create, :destroy], controller: 'wallet_offers'
  end

  resource :redemption, only: [:show, :create], controller: :redemption

  resource :subscription, only: [:edit, :update] do
    get :unsubscribe, on: :member
    get :contest_unsubscribe, on: :member
  end

  resource :contact, controller: 'contact', only: [:create] do
    get :new
    get :thank_you
  end

  resources :contests, only: [:index, :show] do
    resources :entries, only: [:create]
    post :toggle_opt_in_to_daily_reminder
    get :results
    get :results_from_email, action: :results_from_email, as: :results_from_email
  end

  resource :password_reset_request, only: [:new, :create], controller: :password_reset_request
  resource :password_reset, only: [:new, :create], controller: :password_reset

  match '/faq', to: 'static#faq', as: :faq_static
  match '/press', to: 'static#press', as: :press_static
  match '/about', to: 'static#about', as: :about_static
  match '/terms', to: 'static#terms', as: :terms_static
  match '/privacy_policy', to: 'static#privacy', as: :terms_privacy_static
  match '/careers', to: 'static#careers', as: :careers_static

  match '/handle_gigya_login', to: 'gigya_login_handler#create', as: :gigya_login_handler, via: :get
  match '/refer/:user_id/aid/:affiliate_id', to: 'referrals#create', as: :referrer, via: :get
  match '/contest/refer/:user_id/aid/:affiliate_id/contest/:contest_id/(:source)', to: 'contest_referrals#new', as: :contest_referral, via: :get
  match '/deprecated_link', to: 'registration_links#deprecated', as: :deprecated_registration_link, via: :get

  match '/style_guide', to: 'style_guide#show', via: :get
  match '/home/plink_video', to: 'home#plink_video', via: :get
  match '/survey_complete', to: 'survey#complete', via: :get, as: :survey_complete

  root to: "home#index"

  match "/500", to: "errors#general_error"
  match "/404", to: "errors#not_found"

  mount PlinkAdmin::Engine => '/plink_admin'
end
