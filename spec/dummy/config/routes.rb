Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "pages#show_body"
  # get '/dummy', to: "dummy#get_test"
  post '/dummy', to: "dummy#test_request"
  get '/dummy', to: "dummy#test_request"
  get '/dummy/redirect', to: "dummy#test_redirect"
end
