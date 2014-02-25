Rails.application.routes.draw do
  mount PlinkApi::Engine => "/"

  match '/', :to => proc {|env| [200, {}, ["Hello world"]] }, as: :root
end
