class Autocompletes::CookingMethodsController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: Recipe.fuzzy_autocomplete_for(:cooking_methods, autocomplete_query).pluck(:name)
  end
end
