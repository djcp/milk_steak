class Autocompletes::IngredientUnitsController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: RecipeIngredient.unique_units.where(
      'unit like ?', "%#{autocomplete_query}%"
    ).pluck('unit')
  end
end
