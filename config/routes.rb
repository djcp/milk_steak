MilkSteak::Application.routes.draw do
  devise_for :users

  resources :recipes, only: [:index, :new, :create, :show]

  root to: 'homes#index'
end
