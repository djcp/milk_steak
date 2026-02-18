Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :recipes, only: [:index, :destroy] do
      member do
        patch :publish
        patch :reject
        patch :reprocess
      end
    end
    resources :magic_recipes, only: [:new, :create]
  end

  resources :recipes, only: [:index, :new, :create, :show, :edit, :update] do
    member do
      get 'edit', to: 'recipes#edit'
      get ':rando', to: 'recipes#show'
    end
  end

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

  # Health check endpoint for Rails 8
  get 'up' => 'rails/health#show', as: :rails_health_check
end
