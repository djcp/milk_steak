class Autocompletes::IngredientNamesController < ApplicationController
  def index
    render json: Ingredient.unique_names.where(
      'name like ?', "%#{params[:q]}%"
    ).pluck('name') end
end
