class Autocompletes::DietaryRestrictionsController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: Recipe.fuzzy_autocomplete_for(:dietary_restrictions, autocomplete_query).pluck(:name)
  end
end
