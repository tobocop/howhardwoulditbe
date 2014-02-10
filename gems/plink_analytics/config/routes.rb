PlinkAnalytics::Engine.routes.draw do
  root to: "sessions#new"

  resource :sessions, only: [:new, :create, :destroy]
  get '/logout', to: 'sessions#destroy'
  resource :market_share, only: [:show], controller: 'market_share'

  match '/style_guide', to: 'style_guide#show', via: :get
  get '/pie_chart_test_data', to: 'd3_tests#pie_chart_test_data'
  get '/bullet_chart_test_data', to: 'd3_tests#bullet_chart_test_data'
end
