MilkSteak::Application.routes.draw do
  devise_for :users

  resource :recipe, only: [:new, :create]

  root to: 'homes#index'
end
