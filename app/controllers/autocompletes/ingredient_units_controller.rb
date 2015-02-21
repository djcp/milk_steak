class Autocompletes::IngredientUnitsController < ApplicationController
  def index
    render json: RecipeIngredient.unique_units.where(
      'unit like ?', "%#{params[:q]}%"
    ).pluck('unit')
  end
end
