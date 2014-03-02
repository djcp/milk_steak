class Autocompletes::IngredientUnitsController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: RecipeIngredient.unique_units.where(
      'unit like ?', "%#{params[:q]}%"
    ).pluck('unit')
  end
end
