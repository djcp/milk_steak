class Autocompletes::CulturalInfluencesController < ApplicationController
  def index
    render json: Recipe.fuzzy_autocomplete_for(:cultural_influences, params[:q]).pluck(:name)
  end
end
