class Autocompletes::IngredientNamesController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: Ingredient.unique_names.where(
      'lower(ingredients.name) like ?', "%#{like_pattern(autocomplete_query.downcase)}%"
    ).limit(Recipe::AUTOCOMPLETE_LIMIT).pluck('ingredients.name')
  end
end
