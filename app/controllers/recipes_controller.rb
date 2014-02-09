class RecipesController < ApplicationController
  before_filter :redirect_to_login, if: -> {current_user.blank?}

  def new
    @recipe = Recipe.new
    5.times do
      recipe_ingredient = @recipe.recipe_ingredients.build
      recipe_ingredient.ingredient = Ingredient.new
    end
  end

  def create
    recipe = Recipe.create!(recipe_params.merge(user: current_user))
    flash[:message] = t('created')
    redirect_to recipe_path(recipe)
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "Couldn't create that recipe: #{e.inspect}"
    redirect_to '/'
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :name,
      :preparation_time,
      :cooking_time,
      :services,
      :serving_units,
      :directions,
      :servings,
      recipe_ingredients_attributes: [
        :quantity,
        :unit,
        ingredient_attributes: [
          :name
        ]
      ]
    )
  end
end
