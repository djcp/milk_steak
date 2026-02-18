class Autocompletes::IngredientNamesController < ApplicationController
  def index
    render json: Ingredient.unique_names.where(
      'lower(ingredients.name) like ?', "%#{params[:q].downcase}%"
    ).pluck('ingredients.name')
  end
end
