class Autocompletes::IngredientNamesController < ApplicationController
  def index
    render json: Ingredient.unique_names.where(
      'lower(name) like ?', "%#{params[:q].downcase}%"
    ).pluck('name')
  end
end
