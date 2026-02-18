module Admin
  class RecipesController < BaseController
    before_action :find_recipe, only: %i[publish reject reprocess destroy]

    def index
      @status_counts = Recipe.group(:status).count
      @recipes = Recipe.includes(:user, :images).recent
      @recipes = @recipes.by_status(params[:status]) if params[:status].present?
      @recipes = @recipes.paginate(page: params[:page], per_page: 20)
    end

    def publish
      if @recipe.publishable?
        @recipe.update!(status: 'published')
        redirect_to recipe_path(@recipe), notice: 'Recipe published.'
      else
        redirect_to recipe_path(@recipe), alert: 'Recipe cannot be published from its current status.'
      end
    end

    def reject
      @recipe.update!(status: 'rejected')
      redirect_to recipe_path(@recipe), notice: 'Recipe rejected.'
    end

    def reprocess
      if @recipe.reprocessable?
        MagicRecipeJob.perform_later(@recipe.id)
        redirect_to recipe_path(@recipe), notice: 'Recipe re-enqueued for processing.'
      else
        redirect_to recipe_path(@recipe), alert: 'Recipe cannot be reprocessed from its current status.'
      end
    end

    def destroy
      @recipe.destroy!
      redirect_to admin_recipes_path, notice: 'Recipe deleted.'
    end

    private

    def find_recipe
      @recipe = Recipe.includes(:user, :images, :recipe_ingredients, :ingredients).find(params[:id])
    end
  end
end
