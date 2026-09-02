class Autocompletes::IngredientUnitsController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: RecipeIngredient.unique_units.where(
      'unit like ?', "%#{like_pattern(autocomplete_query)}%"
    ).limit(Recipe::AUTOCOMPLETE_LIMIT).pluck('unit')
  end
end
