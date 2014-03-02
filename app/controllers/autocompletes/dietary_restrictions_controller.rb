class Autocompletes::DietaryRestrictionsController < ApplicationController
  def index
    render json: Recipe.fuzzy_autocomplete_for(:dietary_restrictions, params[:q]).pluck(:name)
  end
end
