PlinkApi::Engine.routes.draw do
  namespace :v1 do
    root to: 'api#home'
  end
end
