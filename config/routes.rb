MilkSteak::Application.routes.draw do
  devise_for :users

  resources :recipes, only: [:index, :new, :create, :show, :edit, :update]

  namespace :autocompletes do
    resources :cooking_methods, only: [:index]
    resources :cultural_influences, only: [:index]
    resources :courses, only: [:index]
    resources :dietary_restrictions, only: [:index]
    resources :serving_units, only: [:index]
    resources :ingredient_units, only: [:index]
    resources :ingredient_names, only: [:index]
  end

  root to: 'recipes#index'
end
