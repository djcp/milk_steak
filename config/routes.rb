MilkSteak::Application.routes.draw do
  devise_for :users

  resources :recipes, only: [:index, :new, :create]

  root to: 'homes#index'
end
