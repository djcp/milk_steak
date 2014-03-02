class Autocompletes::CoursesController < ApplicationController
  before_filter :forbidden, if: -> { current_user.blank? }

  def index
    render json: Recipe.fuzzy_autocomplete_for(:courses, params[:q]).pluck(:name)
  end
end
