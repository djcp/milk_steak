module Admin
  class RecipesController < BaseController
    before_action :find_recipe, only: %i[publish reject reprocess destroy]

    after_action :verify_policy_scoped, only: :index

    def index
      authorize :recipe, :index?
      @recipes = policy_scope(Recipe).includes(:user, :images).recent
      @status_counts = scoped_status_counts(policy_scope(Recipe))
      @recipes = @recipes.by_status(params[:status]) if params[:status].present?
      @recipes = @recipes.paginate(page: params[:page], per_page: admin_per_page)
      recipe_ids  = @recipes.map(&:id)
      @run_counts = AiClassifierRun.where(recipe_id: recipe_ids).group(:recipe_id).count
    end

    def publish
      authorize @recipe, :publish?
      if @recipe.publishable?
        @recipe.update!(status: 'published')
        redirect_to admin_recipes_path, notice: 'Recipe published.'
      else
        redirect_to admin_recipes_path, alert: 'Recipe cannot be published from its current status.'
      end
    end

    def reject
      authorize @recipe, :reject?
      @recipe.update!(status: 'rejected')
      redirect_to admin_recipes_path, notice: 'Recipe rejected.'
    end

    def reprocess
      authorize @recipe, :reprocess?
      if @recipe.reprocessable?
        MagicRecipeJob.perform_later(@recipe.id)
        redirect_to admin_recipes_path, notice: 'Recipe re-enqueued for processing.'
      else
        redirect_to admin_recipes_path, alert: 'Recipe cannot be reprocessed from its current status.'
      end
    end

    def destroy
      authorize @recipe, :destroy?
      @recipe.destroy!
      redirect_to admin_recipes_path, notice: 'Recipe deleted.'
    end

    private

    def admin_per_page
      params.fetch(:per_page, 20).to_i.clamp(1, 100)
    end

    def scoped_status_counts(scope)
      scope.group(:status).count.tap do |counts|
        Recipe::STATUSES.each { |status| counts[status] ||= 0 }
      end
    end

    def find_recipe
      @recipe = policy_scope(Recipe).includes(:user, :images, :recipe_ingredients, :ingredients).find(params[:id])
    end
  end
end
