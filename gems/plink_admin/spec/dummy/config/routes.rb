Rails.application.routes.draw do
  mount PlinkAdmin::Engine => "/"

  match '/', :to => proc {|env| [200, {}, ["Hello world"]] }, as: :root

end
