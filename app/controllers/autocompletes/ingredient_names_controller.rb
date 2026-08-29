class Autocompletes::IngredientNamesController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: Ingredient.unique_names.where(
      'lower(ingredients.name) like ?', "%#{autocomplete_query.downcase}%"
    ).pluck('ingredients.name')
  end
end
