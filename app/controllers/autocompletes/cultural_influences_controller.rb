class Autocompletes::CulturalInfluencesController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: Recipe.fuzzy_autocomplete_for(:cultural_influences, autocomplete_query).pluck(:name)
  end
end
