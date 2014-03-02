class Autocompletes::ServingUnitsController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: Recipe.unique_serving_units.where(
      'serving_units like ?', "%#{params[:q]}%"
    ).pluck('serving_units')
  end
end
