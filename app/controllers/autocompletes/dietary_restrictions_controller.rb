class Autocompletes::DietaryRestrictionsController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: Recipe.fuzzy_autocomplete_for(:dietary_restrictions, params[:q]).pluck(:name)
  end
end
