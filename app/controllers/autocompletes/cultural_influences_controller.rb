class Autocompletes::CulturalInfluencesController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: Recipe.fuzzy_autocomplete_for(:cultural_influences, params[:q]).pluck(:name)
  end
end
