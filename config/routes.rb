PlinkPivotal::Application.routes.draw do
  root to: "home#index"

  resource :account, only: [:show, :update], controller: :accounts do
    get :login_from_email, action: :login_from_email, as: :login_from_email
  end

  resources :registrations, only: [:new, :create]
  resources :offers, only: :index
  resources :registration_links, only: [:show]
  resources :share_pages, only: [:show] do
    get :create_share_tracking_record, on: :member
    get :update_share_tracking_record, on: :member
  end
  resource :session, only: [:new, :create, :destroy], as: :plink_session
  resource :tracking, only: [:new], controller: 'tracking' do
    get :hero_promotion_click, action: 'hero_promotion_click'
  end

  resources :rewards, only: [:index]

  resource :wallet, only: [:show] do
    resources :offers, only: [:create, :destroy], controller: 'wallet_offers'
    get :login_from_email, action: :login_from_email, as: :login_from_email
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

  resource :global_login, only: [:new]

  get '/institutions/search', to: 'institutions#search', as: 'institution_search'
  if !Rails.env.production?
    post '/institutions/search_results', to: 'institutions#search_results', as: 'institution_search_results'
    get '/institutions/authentication/:id', to: 'institutions#authentication', as: 'institution_authentication'
    post '/institutions/authenticate', to: 'institutions#authenticate', as: 'institution_authenticate'
    get '/institutions/poll', to: 'institutions#poll', as: 'institution_poll'
    post '/institutions/select', to: 'institutions#select', as: 'institution_selection'
    post '/institutions/text_based_mfa', to: 'institutions#text_based_mfa', as: 'institution_text_based_mfa'

    get '/institution_logins/update_credentials/:id', to: 'institution_logins#update_credentials', as: 'institution_login_update_credentials'
    get '/institution_logins/credentials_updated/:institution_id', to: 'institution_logins#credentials_updated', as: 'institution_login_credentials_updated'

    get '/reverifications/start/:id', to: 'reverifications#start', as: 'reverification_start'
    get '/reverifications/complete', to: 'reverifications#complete', as: 'reverification_complete'
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
  match '/style_guide/emails', to: 'style_guide#emails', via: :get
  match '/home/plink_video', to: 'home#plink_video', via: :get
  match '/survey_complete', to: 'survey#complete', via: :get, as: :survey_complete

  match "/500", to: "errors#general_error"
  match "/404", to: "errors#not_found"

  mount PlinkAdmin::Engine => '/plink_admin'
end
