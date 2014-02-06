PlinkAnalytics::Engine.routes.draw do
  root to: "home#index"

  match '/style_guide', to: 'style_guide#show', via: :get
  get '/pie_chart_test_data', to: 'd3_tests#pie_chart_test_data'
  get '/bullet_chart_test_data', to: 'd3_tests#bullet_chart_test_data'
end
