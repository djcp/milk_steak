class Autocompletes::CookingMethodsController < ApplicationController
  def index
    render json: Recipe.fuzzy_autocomplete_for(:cooking_methods, params[:q]).pluck(:name)
  end
end
