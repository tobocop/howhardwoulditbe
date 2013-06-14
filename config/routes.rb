PlinkPivotal::Application.routes.draw do
  resources :registrations, only: [:new, :create]
  resource :session, only: [:new, :create, :destroy]

  match "/style_guide", to: "style_guide#show", via: :get
  match '/dashboard', to: "dashboard#show", via: :get
  root to: "home#index", via: :get
end
