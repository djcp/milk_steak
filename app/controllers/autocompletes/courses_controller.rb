class Autocompletes::CoursesController < ApplicationController
  def index
    render json: Recipe.fuzzy_autocomplete_for(:courses, params[:q]).pluck(:name)
  end
end
