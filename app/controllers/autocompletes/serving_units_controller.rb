class Autocompletes::ServingUnitsController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: Recipe.unique_serving_units.where(
      'serving_units like ?', "%#{like_pattern(autocomplete_query)}%"
    ).limit(Recipe::AUTOCOMPLETE_LIMIT).pluck('serving_units')
  end
end
