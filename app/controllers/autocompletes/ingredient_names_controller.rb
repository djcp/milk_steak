class Autocompletes::IngredientNamesController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: Ingredient.unique_names.where(
      'lower(name) like ?', "%#{params[:q].downcase}%"
    ).pluck('name') end
end
