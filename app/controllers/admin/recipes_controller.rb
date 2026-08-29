module Admin
  class RecipesController < BaseController
    before_action :find_recipe, only: %i[publish reject reprocess destroy]

    def index
      @status_counts = Recipe.group(:status).count
      @recipes = Recipe.includes(:user, :images).recent
      @recipes = @recipes.by_status(params[:status]) if params[:status].present?
      @recipes = @recipes.paginate(page: params[:page], per_page: 20)
      recipe_ids  = @recipes.map(&:id)
      @run_counts = AiClassifierRun.where(recipe_id: recipe_ids).group(:recipe_id).count
    end

    def publish
      result = RecipeCommands::Publish.new(@recipe).call
      redirect_to recipe_path(@recipe), result.flash_type => result.message
    end

    def reject
      result = RecipeCommands::Reject.new(@recipe).call
      redirect_to recipe_path(@recipe), result.flash_type => result.message
    end

    def reprocess
      result = RecipeCommands::Reprocess.new(@recipe).call
      redirect_to recipe_path(@recipe), result.flash_type => result.message
    end

    def destroy
      result = RecipeCommands::Destroy.new(@recipe).call
      redirect_to admin_recipes_path, result.flash_type => result.message
    end

    private

    def find_recipe
      @recipe = Recipe.includes(:user, :images, :recipe_ingredients, :ingredients).find(params[:id])
    end
  end
end
