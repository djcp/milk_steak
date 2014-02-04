class RecipesController < ApplicationController
  def new
    @recipe = Recipe.new
    5.times do
      recipe_ingredient = @recipe.recipe_ingredients.build
      recipe_ingredient.ingredient = Ingredient.new
    end
  end

  def create

  end
end
