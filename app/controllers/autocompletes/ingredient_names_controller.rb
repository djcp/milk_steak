class Autocompletes::IngredientNamesController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: Ingredient.unique_names.where(
      'name like ?', "%#{params[:q]}%"
    ).pluck('name') end
end
