class Autocompletes::CookingMethodsController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: Recipe.fuzzy_autocomplete_for(:cooking_methods, params[:q]).pluck(:name)
  end
end
