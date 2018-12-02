Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "pages#show_body"
  get '/dummy', to: "dummy#get_test"
  post '/dummy', to: "dummy#post_test"
end
