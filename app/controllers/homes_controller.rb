class HomesController < ApplicationController
  def index
    @recipes = Recipe.includes(:images).recent.paginate(
      page: params.fetch(:page, 1),
      per_page: params.fetch(:per_page, 10)
    )
  end
end
