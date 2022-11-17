Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/", to: "home#index"
  namespace :api do # /api/v1
    namespace :v1 do
      # bin/rails routes 查看生成的路由
      resources :validation_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items
      resources :tags
      resource :users, only: [:create, :show] # create对应POST，show对应GET
    end
  end
end
