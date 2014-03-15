class RecipesController < ApplicationController
  before_filter :redirect_to_login, if: -> {current_user.blank?}

  def new
    @recipe = Recipe.new
    5.times do
      @recipe.recipe_ingredients.build(
        ingredient: Ingredient.new
      )
    end
    4.times do
      @recipe.images.build
    end
  end

  def create
    recipe = Recipe.create!(recipe_params.merge(user: current_user))
    flash[:message] = t('created')
    redirect_to recipe_path(recipe)
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "#{t('invalid_recipe_creation')} #{e.inspect}"
    render :new
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
      :cooking_method_list,
      :cultural_influence_list,
      :course_list,
      :dietary_restriction_list,
      images_attributes: [
        :caption,
        :featured,
        :filepicker_url
      ],
      recipe_ingredients_attributes: [
        :quantity,
        :unit,
        ingredient_attributes: [
          :name
        ]
      ],
    )
  end
end
