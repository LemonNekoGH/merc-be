Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    resources :users do
      get 'message_for_signup', action: :create_message, on: :collection
    end

    resource :sessions do
      get 'message_for_login', action: :create_message, on: :collection
    end
  end
end
