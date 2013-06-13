PlinkPivotal::Application.routes.draw do
  resources :registrations, only: [:new, :create]


  match "/style_guide", to: "style_guide#show"
  match '/dashboard', to: "dashboard#show"
  root to: "home#index"
end
