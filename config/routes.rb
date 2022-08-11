Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      # bin/rails routes 查看生成的路由
      resources :verification_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items
      resources :tags
      resource :users, only: [:create, :show]
    end
  end
end
