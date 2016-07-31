Rails.application.routes.draw do
  resources :carts
  resources :votes
  resources :users
  resources :books do
    collection do
      post 'search'
    end
  end
  resources :vote_sessions
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
