Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  namespace :admin do
    resources :users, only: [:index] do
      member { patch :approve }
    end
    resources :recipes, only: [:index, :destroy] do
      member do
        patch :publish
        patch :reject
        patch :reprocess
      end
    end
    resources :magic_recipes, only: [:new, :create]
    resources :ai_classifier_runs, only: [:index, :show] do
      member { post :rerun }
    end
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

  # Branded error pages (also served via config.exceptions_app)
  get '/400', to: 'errors#show'
  get '/404', to: 'errors#show'
  get '/406', to: 'errors#show'
  get '/422', to: 'errors#show'
  get '/500', to: 'errors#show'

  # Health check endpoint for Rails 8
  get 'up' => 'rails/health#show', as: :rails_health_check
end
