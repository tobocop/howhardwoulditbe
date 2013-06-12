PlinkPivotal::Application.routes.draw do
  resources :registrations, only: :new

  match "/style_guide", to: "style_guide#show"
  root to: "home#index"
end
