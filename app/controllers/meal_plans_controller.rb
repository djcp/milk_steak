class MealPlansController < ApplicationController
  before_filter :redirect_to_login,
    if: -> {current_user.blank?},
    only: [:new]

  def new
    @meal_plan = MealPlan.new
  end
end
