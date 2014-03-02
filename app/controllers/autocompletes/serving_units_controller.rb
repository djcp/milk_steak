class Autocompletes::ServingUnitsController < ApplicationController
  def index
    render json: Recipe.unique_serving_units.where(
      'serving_units like ?', "%#{params[:q]}%"
    ).pluck('serving_units')
  end
end
