class Autocompletes::CoursesController < ApplicationController
  def index
    return render(json: []) if autocomplete_query.nil?

    render json: Recipe.fuzzy_autocomplete_for(:courses, autocomplete_query).pluck(:name)
  end
end
