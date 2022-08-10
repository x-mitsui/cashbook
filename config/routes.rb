Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  post "/users", to: "users#create"
  get "/users/:id", to: "users#show"
  namespace :api do
    namespace :v1 do
      # bin/rails routes 查看生成的路由
      resources :validate_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items
      resources :tags
    end
  end
end
